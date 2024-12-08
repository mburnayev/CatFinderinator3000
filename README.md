# [CatFinderinator3000](https://catfinderinator3000.web.app/)
Fun little multifaceted project that uses a variety of technologies I've used in the past, am currently using, or have wanted to use — all for the sole purpose of publicly archiving my silly kitty :3

## Project overview
This system is comprised of 3 main components:
- Raspberry Pi 4B (with camera and an image classifier)
- Firebase (for app and data authentication, data storage, and webapp deployment)
- Cross-platform application (written in Dart, using Flutter)

The systems starts with the RPi, which has a perpetually running Python script that will record a short video if my cat is detected in the live feed. Having recording the video, the script will push the recorded video to a database, which can then be accessed through an app I created that retrieves the recorded videos from the database.

Here is an abstracted visualization of the project that the above text describes:
<img width="890" alt="diagram" src="https://github.com/user-attachments/assets/86f6d9e6-2e3a-487e-a40c-8943f0ade212">

## Technologies used
- Python
- PyTorch
- OpenCV
- Dart + Flutter
- Firebase Authentication
- Firebase Cloud Storage
- labelImg + Kaggle
- Tensorflow + TFLite
- Tensorflow Custom Model Trainer 
- UTM
- Linux (Raspian, Kali Linux)
- Tmux
- and more(!), which can be found in the timeline and obstacles section

## Note
I originally wanted this project to use a machine learning model to detect my cat specifically, and I nearly succeeded, but there were too many drawbacks to continue using TFLite models for the reasons listed in the timeline and obstacles breakdown<br><br>
That being said, artifacts of my attempts to use Tensorflow can be found in previous commits, and these are my model training results:
<img width="954" alt="1" src="https://github.com/user-attachments/assets/8ce13087-bc4b-4970-83b2-5f3f7a16e139">

After failing to build my own working Tensorflow object detection model, I opted for a motion detection-based approach as a simpler means of finding my cat and to put a lid on this project. However, after implementing it, I found that the results were underwhelming and not nearly as good as I expected (notice the flickering contour which is supposed to bound the moving object):

https://github.com/user-attachments/assets/c7f2efde-9d9a-4e35-a83d-711c75bf03d6

Seeing that I could do a better job, I decided to explore other ML frameworks, and after some initial testing, found that PyTorch was pretty powerful and effective — the rest is history.

## Project Timeline and Obstacles Breakdown
Task | Notes | Resolved?
--- | --- | ---
Create a foundation for an app that can display videos | - | ✅
Preliminary app testing | Spent a lot of time amending Gradle and Kotlin files to use correct SDK versions and dependencies | ✅
Preliminary app testing on iOS | Spent almost two weeks working with CocoaPods, deployed it on an iPad, then something broke. No more iOS, too much headache| ❎
Set up Firebase Authentication and Cloud Storage and configuring app to use it | - | ✅
Find instructions on how to create a custom Tensorflow(lite) model | - | ✅ 
Find an instructive Google Colab on custom model training | Google created many TFLite Google Colabs back around 2020, sadly none of them worked in the cloud | ❎
Install the tflite-model-maker package | Couldn't install it because it needed ScaNN, which is only for x86 processors, found a workaround using Kali Linux using [UTM](https://mac.getutm.app/) | ✅
Train and Validate a TFLite model | The model wasn't very good and had 100% accuracy, see pictures above | 🆗
Install OpenCV and Tensorflow for Python 3.7 on the RPi 3 | Dependency hell is real and there is no greater test of patience than that, but I won after I think a month | ✅
Deploy the model and perform inferencing | Crummy model produced crummy results. Also it ran at low single digit fps (\<3 fps) and detected nothing. Buying a Coral Edge TPU could improve performance, but that was an extra expense I didn't think was worth the investment | 🆗
Put everything together | Bad model, poor performance, didn't implement recording functionality and dropped project | ❎
\---------- | **Hiatus** | ----------
Start project back up | I cannot run main.py and OpenCV is generating a slew of errors | ❎
Install different Python versions to fix OpenCV | Some Python builds broke altogether and others failed to install OpenCV | ❎
\---------- | **Hiatus** | ----------
Start project back up again | Still can't run main.py and OpenCV continues to malfunction | 🆗
Install different Python versions to fix OpenCV | Success! Kind of. Python 3.9.2 and opencv-python==4.5.5.64 work, but now Numpy is having issues | 🆗
Install different Python versions to fix Numpy | Success! Now I can't install OpenCV! | 🆗
3D print a stand for the camera and a fan | Thank you Skibidi Labib <3 | ✅
Look into and install PyTorch for object detection | Pip can't find PyTorch | ❎
Abandon Tensorflow and PyTorch | Both ML libraries are built for 64-bit systems and mine is a 32-bit system, and they run like crud anyways | ✅
Install OpenCV again | Flashed a new 64-bit Raspbian image onto the Pi and installed OpenCV for Python 3.9.2 | ✅
Set static IP address for RPi | - | ✅
Set up X11 forwarding for remote viewing of OpenCV video feed | Holy crap I can't believe this worked, I almost opened a new can of worms looking at qt.qpa plugins for solutions... thank God this works |  ✅
Adjust X11 forwarding to update feed faster and not tamper with FPS | Not necessary in retrospect, this was just for debugging | ❎
Add motion detection algorithm | - | ✅
Add automated recording | Needs fine tuning | ✅
Adjust motion detection algorithm sensitivity | Too many issues, detects way more than just my cat | ❎
Wrap up this project | First complete project version published! | ✅
\---------- | **V1 PUBLISHED** | ----------
Find and implement a ML framework that promises good results | Welcome back PyTorch | ✅
Test ML implementation | Success! I got reliable detections with a pre-built MobileNetV2 model| ✅
Add caching to Flutter app | Mobile caching works (pretty sure), web caching *maybe* works | ✅
Improve cloud storage rules | - | ✅
Add additional bucket rules through Google Cloud Console | - | ✅
Refactor recording frequency | - | ✅
Deploy web app to Firebase  | Accessible at [catfinderinator3000.web.app](https://catfinderinator3000.web.app) | ✅
Run some e2e tests | A couple quirks here and there, but everything looks good! | ✅
Create new release | - | ✅
Wrap up this project | - | ✅
\---------- | **V2 PUBLISHED** | ----------

## Future Work, if Revisited
Task | Priority, if chosen | Done?
--- | --- | ---
Revisit ML frameworks, ~~see if I can create a better performing model using cloud services (Hugging Face, AWS SageMaker, etc.) since building locally was incredibly unviable<br>Would require retaking and relabeling photos of my cat using the USB camera attached to the RPi since the images used for training and testing are too high quality compared to the RPi's camera~~ ...or I could use a pretrained model ! | High | ✅
Deploy the app to the Google Play Store | Medium | ❎
Revisit app, see if I can get it to run on iOS | Low | ❎
Add feature to get user feedback | High | ❎
Fix (add?) "Forgot Password?" button dialog | High | ❎
Add ability to log in with Google Account | Medium | ❎
Add option to log in anonymously | Medium | ❎
QoL: add custom user-based login message | Low | ❎
QoL: make videos list UI less primitive | Low | ❎
QoL: change list entry of seen videos | Low | ❎
QoL: add way to favorite videos | Low | ❎
Web: see if a logged-in user can be routed straight to videos list on site refresh | Low | ❎