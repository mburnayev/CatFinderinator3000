# CatFinderinator3000
Fun(?) little multifaceted project that uses a variety of technologies I've touched down on in the past and/or wanted to use.

## Project overview
This system is comprised of 3 main components:
- Raspberry Pi 4 (with camera)
- Firebase (for app authentication and database)
- Cross-platform application (written in Dart, using Flutter)

The systems starts with the RPi, which is designed to detect my cat, which has a perpetually running Python script that will record a short video if my cat is detected in the live feed. Having recording the video, the script will push the recorded video to a database, which can then be accessed on any platform through an app I created that retrieves the recorded videos from the database.

Here is an abstracted visualization of the project that the above text describes. This needs to be updated...

<img width="563" alt="Screenshot 2023-05-10 at 12 43 26 PM (2)" src="https://github.com/Mooobert/CatFinderinator3000/assets/82725378/e32655af-2f40-4ecb-b26d-d1ba49db03fc">

## Note
I originally wanted this project to use a machine learning model to detect my cat specifically, and I nearly succeeded, but there were too many drawbacks to continue using TFLite models for the reasons listed in the timeline and obstacles breakdown
That being said, I included artifacts of my attempts to use the Tensorflow framework:
[content here]

## Technologies used
- Python
- Dart + Flutter
- labelImg + Kaggle
- OpenCV
- Tensorflow + TFLite
- Tensorflow Custom Model Trainer 
- Firebase Authentication
- Firebase Cloud Storage
- UTM
- Linux (Raspian, Kali Linux)
- AWS S3

## Project Timeline and Obstacles Breakdown
Task | Notes | Resolved?
--- | --- | ---
Create a foundation for an app that can display videos | - | ✅
Preliminary app testing on Web | - | ✅
Preliminary app testing on Android (2023) | Spent a lot of time amending Gradle and Kotlin files to use correct SDK versions and dependencies | ✅
Preliminary app testing on iOS | Spent almost two weeks working with CocoaPods, deployed it on an iPad, then something broke. No more iOS, too much headache| ❎
Set up Firebase Authentication and Cloud Storage and configuring app to use it | Piece of cake, thanks Google | ✅
Find instructions on how to create a custom Tensorflow(lite) model | - | ✅ 
Find an instructive Google Colab on custom model training | Google created many TFLite Google Colabs back around 2020, sadly none of them worked in the cloud | ❎
Install the tflite-model-maker package | Couldn't install it because it needed ScaNN, which is only for x86 processors, found a workaround using Kali Linux using [UTM](https://mac.getutm.app/) | ✅
Train and Validate a TFLite model | The model wasn't very good and had 100% accuracy, see pictures above | 🆗
Install OpenCV and Tensorflow for Python 3.7 on the RPi 3 (2023) | Dependency hell is real and there is no greater test of patience than that, but I won after I think a month | ✅
Deploy the model and perform inferencing | Crummy model produced crummy results. Also it ran at low single digit fps (<3 fps) and detected nothing. Buying a Coral Edge TPU could improve performance, but that was an extra expense I didn't think was worth the investment | 🆗
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
Adjust X11 forwarding to update feed faster and not tamper with FPS | not necessary in retrospect, this was just for debugging | ❎
Add motion detection algorithm | - | ✅
Add automated recording | Needs fine tuning | ✅
Apply final touches to app | QoL stuff -> sort by newest, banner indicating new vid, etc. | -
Deploy app to Web via S3 | in progress | -
Apply final touches to detection algorithm | in progress, need to adjust sensitivity of motion detector | -
Wrap up this README and the project as a whole | in progress | -

## Future Work, if Revisited
<table>
<tr>
<th align="center">
<img width="441" height="1">
<p><small>Task</small></p>
</th>
<th align="center">
<img width="441" height="1">
<p><small>Priority, if chosen</small></p>
</th>
</tr>

<tr>
<td align="left">
Revisit ML frameworks, see if I can create a better performing model using cloud services (Hugging Face, AWS SageMaker, etc.) since building locally was incredibly unviable<br></br>
Would require retaking and relabeling photos of my cat using the USB camera attached to the RPi since the images used for training and testing are too high quality compared to the RPi's camera
</td>
<td align="center">
High
</td>
</tr>

<tr>
<td align="left">
Deploy the app to the Google Play Store
</td>
<td align="center">
Medium
</td>
</tr>

<tr>
<td align="left">
Revisit app, see if I can get it to run on iOS</td>
<td align="center">
Low
</td>
</tr>

</table>
