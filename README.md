[//]: # bqubique - blinnqipa@gmail.com

# Animation Demo

This project is a demo of a challenge which is tailored with custom animations.

## Getting Started

To run the application, open with either with Visual Studio Code or Android Studio and run the app. To run from command line/terminal just type ```flutter run```.
The application has been tested on:
 - MacOS (arm64) as a standalone desktop application,
 - iPhone 14 Pro Max Simulator,
 - Physical Pixel 6 device.

Worth noting, the video only works on Android, iOS since Flutter's official video player package only works with the given OS's.

## Conclusion

There are many points where I want to add my thoughts to improve upon this implementation:
 - AnimatedTextWidget could be more modular, as in creating a model for each of the text's that are going to be replaced during the cycle. (Not enough time)
 - Maybe place a picture in the background for MacOS and Windows since VideoPlayer does not work on MacOS and Windows. (Not a requirement)
 - Maybe AnimatedTextKit package could have been used when switching between seconds and labels in timer countdown. (Tested - does not meet criteria)
 - Implement MVU architecture and Riverpod whenever necessary. (Not a requirement)