"""
Perpetually running module, uses motion detection to (hopefully) detect my cat.
Operations list:
- Record short video of cat if cat is in frame
- Save video to device
- Push video to database
- Delete video from device

Written for Python 3.9.2
Author: Misha Burnayev
"""
print("Script started")
import time, os, threading

import pyrebase
import cv2

print("Configuring PyTorch model parameters...")
import numpy as np
from PIL import Image
import torch
from torchvision import models, transforms

torch.backends.quantized.engine = 'qnnpack'
preprocess = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize(mean = [0.485, 0.456, 0.406], std = [0.229, 0.224, 0.225]),
])
net = models.quantization.mobilenet_v2(pretrained = True, quantize = True)

net = torch.jit.script(net)
print("PyTorch configuration done!")

recording = False
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
    global recording, quit_flag

    while True:
        # Blocks until input is given
        key = input()

        # Raise flag for main thread, exit loop, close thread
        if (key == "q" or key == "quit"):
            if recording:
                print("Cannot quit while recording!")
            else:
                quit_flag = True
                break

def main():
    global recording, quit_flag
    writer = None
    title = ""
    started = time.time()
    last_logged = time.time()
    frame_count = 0

    # Initialize Firebase Cloud Storage connection
    pyrebase_config = {}
    with open("creds_firebase.txt") as f:
        for line in f:
            (key, val) = line.split(" ")
            key, val = key.strip(), val.strip()
            pyrebase_config[key] = val

    firebase = pyrebase.initialize_app(pyrebase_config)
    storage = firebase.storage()
    
    # Start a key listener in a separate thread to quit the program
    key_listener_thread = threading.Thread(target = check_keys)
    key_listener_thread.daemon = True
    key_listener_thread.start()
    print("Input daemon launched, waiting for input...")

    # Initialize motion detection variables
    frames_written = 0
    cooldown = 0
    num_recordings = 0

    cap = cv2.VideoCapture(0)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 360)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 360)
    cap.set(cv2.CAP_PROP_FPS, 30)

    if not cap.isOpened():
        print("Cannot open camera!")
        return

    print("Camera ready!")
    with torch.no_grad():
        while True:
            # Rudimentary restriction to prevent too many videos from being pushed: reset # of recordings at midnight
            time_struct = time.localtime()
            if time_struct.tm_hour == 0 and time_struct.tm_min == 0:
                num_recordings = 0
            
            if num_recordings < 10:
                ret, frame = cap.read()
                if not ret:
                    print("Can't retrieve frame, exiting ...")
                    break

                # Rotate frame 180 degrees since I mounted the camera upside down :P
                frame = cv2.rotate(frame, cv2.ROTATE_180)
                frame = increase_brightness(frame, value = 20)
                frame = frame[:, :, [2, 1, 0]]

                input_tensor = preprocess(frame)
                input_batch = input_tensor.unsqueeze(0)
                output = net(input_batch)

                top = list(enumerate(output[0].softmax(dim=0)))
                top.sort(key=lambda x: x[1], reverse=True)
                print("-----")
                for idx, val in top[:5]:
                    print(f"{val.item()*100:.2f}% {idx}")
                print("-----")


                # frame_count += 1
                # now = time.time()
                # if now - last_logged > 1:
                #     # print(f"{frame_count / (now-last_logged)} fps")
                #     last_logged = now
                #     frame_count = 0

                # if len(contours) > 0 and frames_written < 401:
                #     # Start recording if the last frame had no motion and we saved the last video
                #     # Contour State: () -> (...)
                #     if last_motion == () and not recording:
                #         print("Video now recording...")
                #         recording = True

                #         title = time.strftime("Video_%y.%m.%d_%H.%M.%S.mp4", time.localtime())
                #         writer = cv2.VideoWriter(title, cv2.VideoWriter_fourcc(*"avc1"), 30.0, (640, 480))
                        
                #     # Record frames if we are recording and the contours are valid
                #     # Contour State: (...) -> (...)
                #     for contour in contours:
                #         if cv2.contourArea(contour) < 1000:
                #             continue

                #         (c_x, c_y,c_w, c_h) = cv2.boundingRect(contour)
                #         cv2.rectangle(frame, (c_x, c_y), (c_x + c_w, c_y + c_h), (0, 255, 0), 3)

                #         if recording and writer is not None:
                #             frames_written += 1
                #             writer.write(frame)
                                
                # else:
                #     # Stop recording if the last frame had no motion/contours found but were previously recording
                #     # Contour State: (...) -> ()
                #     if last_motion != () and recording:
                #         recording = False

                #         writer.release()
                #         writer = None
                #         print("Video recorded!")

                #         # Only push longer recordings, sometimes bogus contours are detected and 'blip' videos are created
                #         if os.path.getsize(title) > 1000:
                #             path_cloud = "videos/" + title
                #             storage.child(path_cloud).put(title)
                #             time.sleep(1)
                #             num_recordings += 1
                #             print("Video pushed to Firebase!")

                #         os.remove(title)
                #         frames_written = 0
                
                # last_motion = contours

                
                # Exit main thread
                if quit_flag:
                    print("Exiting...")
                    break

    # Cleanup
    cap.release()

if __name__ == "__main__":
    main()
