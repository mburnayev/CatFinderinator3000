"""
Perpetually running module, uses trained model to detect calico cats.
If cat is detected in frame, record a short video of cat, save video to device,
push video to database, then delete video from device.

Author: Misha Burnayev
Date: 02/05/2023 (dd/mm/yyyy)
"""
import cv2, time, pyrebase

def main():
    config = {}
    with open("credentials.txt") as f:
        for line in f:
            (key, val) = line.split(" ")
            key, val = key.strip(), val.strip()
            config[key] = val
    print(config)

    firebase = pyrebase.initialize_app(config)
    storage = firebase.storage()

    path_cloud = "videos/x1.jpg"
    path_local = "x.jpg"
    storage.child(path_cloud).put(path_local)

def main2():
    cap = cv2.VideoCapture(0)
    fcc = cv2.VideoWriter_fourcc(*'XVID')
    fps = 30.0
    dims = (480, 480)
    recording = False
    writer = None

    if not cap.isOpened():
        print("Cannot open camera!")
        return
    
    while True:
        # read camera frame
        ret, frame = cap.read()
        if not ret:
            print("Can't retrieve frame, exiting ...")
            break

        # display frame
        cropped_frame = frame[0:480, 80:560]
        cv2.imshow("Camera Feed", cropped_frame)

        key = cv2.waitKey(1)
        # record video if user presses 'r' key
        if key == ord('r') and not recording:
            title = time.strftime("Video_%d.%m.%y_%H.%M.%S.avi", time.localtime())
            print("Video now recording")
            writer = cv2.VideoWriter(title, fcc, fps, dims)
            recording = True

        # add frame to video if recording
        if recording:
            writer.write(cropped_frame)
        
        # # stop recording video if user presses 's' key
        if key == ord('s') and recording:
            print("Video recorded!")
            recording = False
            writer.release()

        # exit loop and terminate program if user presses 'q' key
        if key == ord('q'):
            break

    # cleanup
    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()

