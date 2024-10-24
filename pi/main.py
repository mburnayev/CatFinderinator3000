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
import time, os, threading

import pyrebase
import cv2

pyrebase_config = {}
with open("creds_firebase.txt") as f:
    for line in f:
        (key, val) = line.split(" ")
        key, val = key.strip(), val.strip()
        pyrebase_config[key] = val

firebase = pyrebase.initialize_app(pyrebase_config)
storage = firebase.storage()

recording = False
writer = None
title = ""
quit_flag = False

def check_keys():
    global recording, quit_flag

    while True:
        key = input()  # Blocks until input is given

        # Raise flag for main thread, exit loop, close thread
        if (key == "q" or key == "quit"):
            if recording:
                print("Cannot quit while recording!")
            else:
                quit_flag = True
                break

def main():
    print("Script started")
    global storage, recording, writer, title, quit_flag
    
    # Start a key listener in a separate thread:
    # This is done so I can test remotely without having to rely on
    # imshow() and waitKey() using X11 forwarding since it's really slow
    key_listener_thread = threading.Thread(target = check_keys)
    key_listener_thread.daemon = True
    key_listener_thread.start()
    print("Input daemon launched, waiting for input...")

    # Initialize motion detection variables
    initState = None
    last_motion = tuple()
    frames_written = 0
    cooldown = 0

    cap = cv2.VideoCapture(0)

    if not cap.isOpened():
        print("Cannot open camera!")
        return

    while True:
        ret, frame = cap.read()
        if not ret:
            print("Can't retrieve frame, exiting ...")
            break

        # Rotate frame 180 degrees since I mounted the camera upside down :P
        frame = cv2.rotate(frame, cv2.ROTATE_180)

        gray_image = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        gray_frame = cv2.GaussianBlur(gray_image, (21, 21), 0)

        if initState is None:
            initState = gray_frame
            continue

        # Calculate difference between initial and gray frames
        threshold_frame = cv2.absdiff(initState, gray_frame)
        threshold_frame = cv2.threshold(threshold_frame, 30, 255, cv2.THRESH_BINARY)[1]
        threshold_frame = cv2.dilate(threshold_frame, None, iterations = 2)

        # Create contours for moving objects in frame
        contours, _ = cv2.findContours(threshold_frame.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        if len(contours) > 0:
            # Start recording if the last frame had no motion and we saved the last video
            # Contour State: () -> (...)
            if last_motion == () and not recording:
                print("Video now recording...")
                recording = True

                title = time.strftime("Video_%y.%m.%d_%H.%M.%S.mp4", time.localtime())
                writer = cv2.VideoWriter(title, cv2.VideoWriter_fourcc(*"avc1"), 31.0, (640, 480))
                
            # Record frames if we are recording and the contours are valid
            # Contour State: (...) -> (...)
            for contour in contours:
                if cv2.contourArea(contour) < 1000:
                    continue

                (c_x, c_y,c_w, c_h) = cv2.boundingRect(contour)
                cv2.rectangle(frame, (c_x, c_y), (c_x + c_w, c_y + c_h), (0, 255, 0), 3)

                if recording and writer is not None:
                    frames_written += 1
                    writer.write(frame)
                        
        else:
            # Stop recording if the last frame had no motion/contours found but were previously recording
            # Contour State: (...) -> ()
            if last_motion != () and recording:
                recording = False

                writer.release()
                writer = None
                path_cloud = "videos/" + title
                storage.child(path_cloud).put(title)
                time.sleep(1)  # Delay to publish video to Firebase (just in case)
                os.remove(title)
                frames_written = 0
                print("Video recorded!")
            # else:
            #     # Fallthrough case is that we saw no motion this frame had no motion previously
            #     # Contour State: () -> ()
            #     # Nevertheless, update and potentially reset cooldown if necessary
            #     cooldown += 1
            #     if cooldown == 1800:
            #         cooldown = 0
            #         frames_written = 0
        
        last_motion = contours
        
        # Exit main thread
        if quit_flag:
            print("Exiting...")
            break

    # Cleanup
    cap.release()

if __name__ == "__main__":
    main()
