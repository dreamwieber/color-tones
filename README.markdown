ColorTones is an iOS Core Audio sample project that builds on several basic principles of musical instrument design: triggers, envelopes, wave generators. 

It includes CTMusicHelper, a class which ports concepts from the Overtone project to Objective C, by making use of OCTotallyLazy - a functional programming extension to Objective C collections. 

This project is based upon 
https://github.com/dreamwieber/sine-wave
https://github.com/dreamwieber/noise-trigger
https://github.com/dreamwieber/shaped-noise
https://github.com/dreamwieber/harmonic-drone


Run:

    git submodule init
    git submodule update
    pod install

Open the generated .xcworkspace file and add TheAmazingAudioEngine/TheAmazingAudioEngine.xcproject to your project, at the top level.

Use the .xcworkspace file to build and run the project.

     
