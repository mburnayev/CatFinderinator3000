# CatFinderinator3000
Fun little multifaceted project that uses a variety of technologies I've touched down on in the past and/or wanted to use.

## Project overview
This system is composed of a computer with a camera, an image segmentation model trained to detect calico cats, code on the computer that will record a video if the camera using the model detects a calico cat, more code that will push the recorded video to a database, and a user phone with an app that can retrieve uploaded videos from the database.

At the most abstracted level, this is a visualization of the project.

<img width="563" alt="Screenshot 2023-05-10 at 12 43 26 PM (2)" src="https://github.com/Mooobert/CatFinderinator3000/assets/82725378/e32655af-2f40-4ecb-b26d-d1ba49db03fc">

## Technologies used
- Python
- Dart
- Flutter app framework
- Kaggle
- OpenCV
- ~~Custom Model Trainer using Tensorflow~~
- ~~Semantic Segmentation using Tensorflow~~
- Firebase Authentication
- Firebase Cloud Storage
- Autodesk Fusion 360
- UltiMaker Cura

## Project Obstacle Breakdown
Obstacle | Notes | Resolved?
--- | --- | ---
Finding instructions on how to create a custom tensorflow(lite) model |  | ✅ 
Find an instructive Google Colab on custom model training | Google created many TFLite Google Colabs back in 2021, none of them worked | ❎
Installing the tflite-model-maker library | couldn't do it because ScaNN is for x86 only, found a workaround using Kali Linux using UTM | ✅

