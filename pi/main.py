"""
Perpetually running module, uses motion detection to (hopefully) detect my cat.
Operations list:
- Record short video of cat if cat is in frame
- Save video to device
- Push video to database
- Delete video from device

Written for Python 3.9.2
Author: Misha Burnayev

Notes:
- Native frame resolution is 640x480, straying from this will results in the
  VideoWriter failing to write the frame correctly, creating a corrupted video

- Inferencing done by the MobileNetV2 model on the native resolution has the
  script run at ~6fps, but could be made faster if a smaller frame size is used

- One or more of the three following lines accelerate the rate at which frames are
  captured, this issue doesn't occur when PyTorch frame operation aren't performed
    input_tensor = ...
    input_batch = ...
    output = ...

- idx is the index for objects/classes from this map: https://gist.github.com/yrevar/942d3a0ac09ec9e5eb3a
  all 'proper' cats (domestic or wild) have indexes 281-287 (inclusive)
"""
print("Script started")
import time, os, threading

import pyrebase
import cv2

print("Configuring PyTorch model parameters...")
import torch
from torchvision import models, transforms

torch.backends.quantized.engine = "qnnpack"
preprocess = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize(mean = [0.485, 0.456, 0.406], std = [0.229, 0.224, 0.225]),
])
net = models.quantization.mobilenet_v2(pretrained = True, quantize = True)

net = torch.jit.script(net)
print("PyTorch configuration done!")

# Initialize Firebase Cloud Storage connection
pyrebase_config = {}
with open("creds_firebase.txt") as f:
    for line in f:
        (key, val) = line.split(" ")
        key, val = key.strip(), val.strip()
        pyrebase_config[key] = val

# firebase = pyrebase.initialize_app(pyrebase_config)
# storage = firebase.storage()

recording = False
writer = None
title = ""
manual_mode = False
quit_flag = False

def increase_brightness(img, value = 30):
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    h, s, v = cv2.split(hsv)

    lim = 255 - value
    v[v > lim] = 255
    v[v <= lim] += value

    final_hsv = cv2.merge((h, s, v))
    img = cv2.cvtColor(final_hsv, cv2.COLOR_HSV2BGR)
    return img

def check_keys():
    global storage, recording, writer, title, manual_mode, quit_flag

    while True:
        key = input()

        # Record video if user presses 'r' key, will change to record when a detection occurs
        if key == 'r' and not recording:
            print("Video now recording...")
            manual_mode = True
            recording = True

            title = time.strftime("Video_%y.%m.%d_%H.%M.%S.mp4", time.localtime())
            writer = cv2.VideoWriter(title, cv2.VideoWriter_fourcc(*"avc1"), 10.0, (640, 480))

        # Stop recording video if user presses 's' key, clear VideoWriter
        elif key == 's' and recording:
            print("Video recorded!")
            recording = False

            writer.release()
            writer = None
            path_cloud = "videos/" + title
            # storage.child(path_cloud).put(title)
            time.sleep(1)  # delay to publish video to Firebase (just in case)
            # os.remove(title)
            manual_mode = False

        # Raise flag for main thread, exit loop, close thread
        if (key == "q" or key == "quit"):
            if recording:
                print("Cannot quit while recording!")
            else:
                quit_flag = True
                break

def main():
    global recording, writer, title, manual_mode, quit_flag

    cap = cv2.VideoCapture(0)

    if not cap.isOpened():
        print("Cannot open camera!")
        return
    
    # Start a key listener in a separate thread to quit the program
    key_listener_thread = threading.Thread(target = check_keys)
    key_listener_thread.daemon = True
    key_listener_thread.start()
    print("Input daemon launched, waiting for input...")

    # Initialize motion detection variables
    frames_written = 0
    empty_frames = 0
    num_recordings = 0

    print("Camera ready!")
    with torch.no_grad():
        while True:
            # Rudimentary restriction to prevent too many videos from being pushed: reset # of recordings at midnight
            time_struct = time.localtime()
            if time_struct.tm_hour == 0 and time_struct.tm_min == 0:
                num_recordings = 0
            
            if num_recordings < 100:
                ret, frame = cap.read()
                if not ret:
                    print("Can't retrieve frame, exiting ...")
                    break

                # Rotate frame 180 degrees since I mounted the camera upside down :P
                frame = cv2.rotate(frame, cv2.ROTATE_180)
                frame = increase_brightness(frame, value = 20)

                frame_restruct = frame[:, :, [2, 1, 0]]
                input_tensor = preprocess(frame_restruct)
                input_batch = input_tensor.unsqueeze(0)
                output = net(input_batch)

                top = list(enumerate(output[0].softmax(dim = 0)))
                top.sort(key = lambda x: x[1], reverse = True)

                cat_found = False
                for idx, val in top[:10]:
                    # print(f"{val.item()*100:.2f}% {idx}")
                    if idx > 280 and idx < 288:
                        cat_found = True
                        # print("CAT FOUND!!!")

                # Manual recording precedes automatic recording in priority
                if manual_mode:
                    if recording and writer is not None:
                        writer.write(frame)
                else:
                    if cat_found:
                        # State: () -> (...) — Start recording if cat spotted and not actively recording
                        if not recording:
                            print("Video now recording...")
                            recording = True

                            title = time.strftime("Video_%y.%m.%d_%H.%M.%S.mp4", time.localtime())
                            writer = cv2.VideoWriter(title, cv2.VideoWriter_fourcc(*"avc1"), 10.0, (640, 480))
                        
                        # State: (...) -> (...) — At this point recording has to be True, so we are safe to record frames
                        if frames_written < 1001 and writer is not None:
                            frames_written += 1
                            writer.write(frame)
                        
                    else:
                        if empty_frames >= 500:
                            # State: () -> () — Stop recording if no detections for a while and recording was True
                            if recording:
                                writer.release()
                                writer = None
                                print("Video recorded!")

                                # Only push longer recordings, filter out 'blip' videos
                                if os.path.getsize(title) > 1000:
                                    path_cloud = "videos/" + title
                                    # storage.child(path_cloud).put(title)
                                    time.sleep(1)
                                    num_recordings += 1
                                    print("Video pushed to Firebase!")

                                # os.remove(title).
                                frames_written = 0
                                empty_frames = 0
                                recording = False
                        else:
                            # State: (...) -> () — Nothing seen? Take note!
                            empty_frames += 1

                # Exit main thread
                if quit_flag:
                    print("Exiting...")
                    break

    # Cleanup
    cap.release()

if __name__ == "__main__":
    main()
