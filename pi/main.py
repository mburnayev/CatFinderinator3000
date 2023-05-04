"""
Perpetually running module, uses trained model to detect calico cats.
If cat is detected in frame, record a short video of cat, save video to device,
push video to database, then delete video from device.

Author: Misha Burnayev
Date: 02/05/2023 (dd/mm/yyyy)
"""
import cv2

def main():
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print("Cannot open camera")
        return
        
    while True:
        # read camera frame
        ret, frame = cap.read()
        if not ret:
            print("Can't retrieve frame, exiting ...")
            break

        # show camera frame
        cv2.imshow("Camera Feed", frame)
        # 
        
        if cv2.waitKey(1) == ord('q'):
            break

    # cleanup
    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()

