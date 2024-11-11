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
    print("Script started")
    global recording, quit_flag
    writer = None
    title = ""

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
    initState = None
    last_motion = tuple()
    frames_written = 0
    cooldown = 0
    num_recordings = 0

    cap = cv2.VideoCapture(0)

    if not cap.isOpened():
        print("Cannot open camera!")
        return

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
            gray_image = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            gray_frame = cv2.GaussianBlur(gray_image, (21, 21), 0)

            if initState is None:
                initState = gray_frame
                continue

            # Calculate difference between initial and gray frames
            threshold_frame = cv2.absdiff(initState, gray_frame)
            # Is the second/threshold argument range 0-255?
            threshold_frame = cv2.threshold(threshold_frame, 64, 255, cv2.THRESH_BINARY)[1]
            threshold_frame = cv2.dilate(threshold_frame, None, iterations = 2)

            # Create contours for moving objects in frame
            contours, _ = cv2.findContours(threshold_frame.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

            if len(contours) > 0 and frames_written < 401:
                # Start recording if the last frame had no motion and we saved the last video
                # Contour State: () -> (...)
                if last_motion == () and not recording:
                    print("Video now recording...")
                    recording = True

                    title = time.strftime("Video_%y.%m.%d_%H.%M.%S.mp4", time.localtime())
                    writer = cv2.VideoWriter(title, cv2.VideoWriter_fourcc(*"avc1"), 30.0, (640, 480))
                    
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
                    print("Video recorded!")

                    # Only push longer recordings, sometimes bogus contours are detected and 'blip' videos are created
                    if os.path.getsize(title) > 1000:
                        path_cloud = "videos/" + title
                        storage.child(path_cloud).put(title)
                        time.sleep(1)
                        num_recordings += 1
                        print("Video pushed to Firebase!")

                    os.remove(title)
                    frames_written = 0
            
            last_motion = contours
            
            # Exit main thread
            if quit_flag:
                print("Exiting...")
                break

    # Cleanup
    cap.release()

if __name__ == "__main__":
    main()
