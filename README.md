# Senior-Capstone-CS11
A Gesture Recognition Keyboard for iOS. Our app provides a system keyboard that allows the user to use a series of motion gestures to type out text in standard input fields.

## This project includes:
  - Building a machine learning model to test user gestures against (We used Apple's CreateML and CoreML tools)
  - Creating training data and using this to generate a vaible model for matching
  - Making a keyboard interface for users to interact with and tell us when we should be listentening for gestures
  - Creating a user trainer for use by the user to learn our gesture set

### To build this project:
  - download the git repository, XCode 11.3, and MacOS 10.15 (if you want to build your own CoreML model)
  - run `git submodule init` and `git submodule update` to pull Snapkit into your repository
#### **This only works if you have an SSH key registered with Github. Info here: https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
  - open the main project file (`GestureRecognition.xcodeproj`) in XCode
  - Build snapkit for your local mac (see img below)
    ![image](https://github.com/OSU-CS11/documents/blob/master/Screen%20Shot%202020-03-16%20at%2011.42.20%20PM.png?raw=true)
  - After this builds, build the project for your target device.
    ![image](https://github.com/OSU-CS11/documents/blob/master/appBuild_phone.png?raw=true)
