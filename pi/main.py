"""
Perpetually running module, uses trained model to detect calico cats.
If cat is detected in frame, record a short video of cat, save video to device,
push video to database, then delete video from device.

Author: Misha Burnayev
Date: 02/05/2023 (dd/mm/yyyy)
"""
import cv2, time, os, pyrebase

config = {}
with open("credentials.txt") as f:
    for line in f:
        (key, val) = line.split(" ")
        key, val = key.strip(), val.strip()
        config[key] = val

firebase = pyrebase.initialize_app(config)
storage = firebase.storage()

def main():
    cap = cv2.VideoCapture(0)
    # mp4 codec that doesn't cause FFMPEG to print warnings and is
    # compatible with native Chrome Web player and Android ExoPlayer
    fcc = cv2.VideoWriter_fourcc(*"avc1")
    fps = 30.0
    dims = (480, 480)
    recording = False
    writer = None
    title = "failed.mp4"
    num_det_frames = 0

    if not cap.isOpened():
        print("Cannot open camera!")
        return
    
    while True:
        print("entered loop")
        # read camera frame
        ret, frame = cap.read()
        if not ret:
            print("Can't retrieve frame, exiting ...")
            break

        # display frame
        cropped_frame = frame[0:480, 80:560]
        # cv2.imshow("Camera Feed", cropped_frame)
        print(cropped_frame)

        key = cv2.waitKey(1)
        # record video if user presses 'r' key
        if key == ord('r') and not recording:
            title = time.strftime("Video_%d.%m.%y_%H.%M.%S.mp4", time.localtime())
            print("Video now recording")
            writer = cv2.VideoWriter(title, fcc, fps, dims)
            recording = True

        # add frame to video if recording
        if recording:
            writer.write(cropped_frame)
        
        # stop recording video if user presses 's' key
        if key == ord('s') and recording:
            print("Video recorded!")
            recording = False
            writer.release()
            path_cloud = "videos/" + title
            path_local = title
            storage.child(path_cloud).put(path_local)
            time.sleep(1.5)
            os.remove(title)

        # exit loop and terminate program if user presses 'q' key
        if key == ord('q'):
            break
    
    # cleanup
    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()

