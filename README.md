# CatFinderinator3000
Fun little multifaceted project that uses a variety of technologies I've touched down on in the past and/or wanted to use.

## Project overview
This system is composed of a computer with a camera, an image segmentation model trained to detect calico cats, code on the computer that will record a video if the camera using the model detects a calico cat, more code that will push the recorded video to a database, and a user phone with an app that can retrieve uploaded videos from the database.

At the most abstracted level, this is a visualization of the project.

<img width="563" alt="Screenshot 2023-05-10 at 12 43 26 PM (2)" src="https://github.com/Mooobert/CatFinderinator3000/assets/82725378/e32655af-2f40-4ecb-b26d-d1ba49db03fc">

## Technologies used
- Python
- Dart + Flutter
- Kaggle
- OpenCV
- ~~Custom Model Trainer using Tensorflow~~
- ~~Semantic Segmentation using Tensorflow~~
- Firebase Authentication
- Firebase Cloud Storage

## Project Obstacles Breakdown
Obstacle | Notes | Resolved?
--- | --- | ---
Create a foundation for an app that can display videos | - | ✅
Preliminary app testing on Web | - | ✅
Preliminary app testing on Android (2023) | Spent a lot of time amending Gradle and Kotlin files to use correct SDK versions and dependencies | ✅
Preliminary app testing on iOS | Spent almost two weeks working with CocoaPods, deployed it on an iPad, then something broke. No more iOS, too much headache| ❎
Set up Firebase Authentication and Cloud Storage and configuring app to use it | Piece of cake, thanks Google | ✅
Find instructions on how to create a custom Tensorflow(lite) model | - | ✅ 
Find an instructive Google Colab on custom model training | Google created many TFLite Google Colabs back around 2020, sadly none of them worked in the cloud | ❎
Install the tflite-model-maker package | Couldn't install it because it needed ScaNN, which is only for x86 processors, found a workaround using Kali Linux using [UTM](https://mac.getutm.app/) | ✅
Train and Validate a TFLite model | The model wasn't very good and had 100% accuracy, see pictures below | 🆗
Install OpenCV and Tensorflow for Python 3.7 on the RPi 3 (2023) | Dependency hell is real and there is no greater test of patience than that, but I won after I think a month | ✅
Deploy the model and perform inferencing | Crummy model produced crummy results. Also it ran at low single digit fps and detected nothing | 🆗
Put everything together (2023) | Bad model, poor performance, didn't implement recording functionality and dropped project | ❎
\- | **Hiatus** | -
Start project back up | I cannot run main.py and OpenCV is generating a slew of errors | ❎
Install different Python versions to fix OpenCV | Some Python builds broke altogether and others failed to install OpenCV | ❎
\- | **Hiatus** | -
Start project back up again | Still can't run main.py and OpenCV continues to malfunction | 🆗
Install different Python versions to fix OpenCV | Success! Kind of. Python 3.9.2 and opencv-python==4.5.5.64 work, but now Numpy is having issues | 🆗
Install different Python versions to fix Numpy | Success! Now I can't install OpenCV! | 🆗
3D print a stand for the camera and a fan | Thank you Skibidi Labib <3 | ✅
Look into PyTorch for object detection | - | ✅
Install PyTorch | pip can't find PyTorch | ❎
Abandon Tensorflow and Pytorch | Both ML libraries are built for 64-bit systems and mine is a 32-bit system, and they run like crud anyways | ✅
Install OpenCV again | Flashed a new 64-bit Raspbian image onto the Pi and installed OpenCV for Python 3.9.2 | ✅
Set static IP address for RPi | - | ✅
Set up X11 forwarding for remote viewing of OpenCV video feed | holy crap I can't believe this worked, I almost opened a new can of worms looking at qt.qpa plugins for solutions... thank God this works |  ✅
Add motion detection algorithm | in progress | -
Add automated recording | in progress | -
Adjust X11 forwarding to update feed faster and not tamper with FPS | in progress | -
