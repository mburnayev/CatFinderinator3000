"""
Perpetually running module, uses trained model to detect calico cats.
If cat is detected in frame, record a short video of cat, save video to device,
push video to database, then delete video from device.

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
    global storage, recording, writer, title, quit_flag

    while True:
        key = input()  # Blocks until input is given
        
        # Record video if user presses 'r' key, will change to record when a detection occurs
        if key == 'r' and not recording:
            print("Video now recording...")
            recording = True

            title = time.strftime("Video_%y.%m.%d_%H.%M.%S.mp4", time.localtime())
            writer = cv2.VideoWriter(title, cv2.VideoWriter_fourcc(*"avc1"), 30.0, (640, 480))

        # Stop recording video if user presses 's' key, clear VideoWriter
        elif key == 's' and recording:
            print("Video recorded!")
            recording = False

            writer.release()
            writer = None
            path_cloud = "videos/" + title
            storage.child(path_cloud).put(title)
            time.sleep(1)  # delay to publish video to Firebase (just in case)
            os.remove(title)

        # Raise flag for main thread, exit loop, close thread
        elif key == 'q':
            if recording:
                print("Cannot quit while recording!")
            else:
                quit_flag = True
                break

def main():
    print("Script started")
    global recording, writer, quit_flag

    cap = cv2.VideoCapture(0)

    if not cap.isOpened():
        print("Cannot open camera!")
        return
    
    # Start a key listener in a separate thread:
    # This is done so I can test remotely without having to rely on
    # imshow() and waitKey() using X11 forwarding since it's really slow
    key_listener_thread = threading.Thread(target = check_keys)
    key_listener_thread.daemon = True
    key_listener_thread.start()
    print("Input daemon launched, waiting for input...")

    while True:
        ret, frame = cap.read()
        if not ret:
            print("Can't retrieve frame, exiting ...")
            break

        frame = cv2.rotate(frame, cv2.ROTATE_180)

        if recording and writer is not None:
            writer.write(frame)
        
        # Exit main thread
        if quit_flag:
            print("Exiting...")
            break

    # Cleanup
    cap.release()

if __name__ == "__main__":
    main()
