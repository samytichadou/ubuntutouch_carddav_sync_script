# ubuntutouch carddav sync script

A simple bash script to **setup your carddav contact**.

The script also have the ability to setup an **auto synchronisation** (hourly, daily, weekly...) and to add a **sync button** in your launcher.

You can use this script two ways : locally on and from your phone, or through adb (android debug tool) on your computer through a terminal.

- First you have to put the script file on your phone storage. 

    You can do it by **connecting your phone to a computer and using the file explorer*.
    
    You can also **use adb** : **with your phone connected to your computer (with usb debugging activated), you can use this command : `adb push filepath_on_your_system destination_filepath_on_phone`**
- Then you have to make your file executable and launch it. 
    - If you are doing this through adb, first connect to your phone shell with this command `adb shell`, if you are doing this locally, ignore this last command.
    - Go into the folder you copied the script `cd script_folder` 
    - Make it executable `chmod -x ./scriptfile`.
    - You can now run the script and follow its instructions `./scriptfile` 
