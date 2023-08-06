<h2>GUI --> User guide</h2>

>
> <p align="center"> <img src="https://raw.githubusercontent.com/BlassGO/AutoIMG_Doc/main/images/tool.png"></p>
> 
> **1.** Search for connected devices.
> 
> **2.** Allows you to select files for installation (One by one, the order in which they are loaded will also be the order in which they will be installed).
> 
> **3.** Allows you to specify which partition of the device the selected file should be installed on (Can be edited before uploading a next file).
> 
> **4.** It allows you to clean all the current configurations, that is, to empty the list of selected files and to restore all the configurations to their initial point.
> 
> **5.** Start the installation process.
> 
> **6.** It indicates that after the installation of files by Fastboot, it should be used to format the device.
> 
> **7.** Indicates that any files that have direction to the `vbmeta*` partition should be installed with the `--disable-verity --disable-verification` parameters.
> 
> **8.** Indicates that the device must be rebooted when the entire installation process is complete.


>
> <p align="center"> <img src="https://raw.githubusercontent.com/BlassGO/AutoIMG_Doc/main/images/tool2.png"></p>
> 
> **1.** Allows you to do a normal reboot.
> 
> **2.** Allows you to reboot in Fastboot mode (or FastbootD depending on the default mode).
> 
> **3.** Allows you to reboot in Recovery mode.


>
> <p align="center"> <img src="https://raw.githubusercontent.com/BlassGO/AutoIMG_Doc/main/images/tool3.png"></p>
> 
> **1.** Opens the installation manager, which allows you to review and modify the list of files for the installation.
> <p align="center"> <img src="https://raw.githubusercontent.com/BlassGO/AutoIMG_Doc/main/images/install_manager.png"></p>
> 
> **2.** Opens the device manager, which allows you to review and select a device for installation.
> <p align="center"> <img src="https://raw.githubusercontent.com/BlassGO/AutoIMG_Doc/main/images/device_manager.png"></p>
> 
> **3.** Allows you to select the default mode in which the entire Tool will work. Always use `Fastboot` or `FastbootD`.
> 
> **4.** Allows you to define a SLOT (`a`\\`b`) for the partitions of the entire installation. During installation, it automatically checks if the name of the destination partition of each file has a SLOT defined in its name (`_a`\\`_b`) and if it is not found, it checks if there is a partition with the name base and with the extension of the default SLOT (system `_` SLOT), directing the file towards it. The `auto` state ensures to always use the active SLOT of the device.
> 
> **5.** Indicates that the selected preferences must be remembered at each opening of the Tool.
> 
> **6.** By default, it is always checked if the size of the installation file is not larger than the target partition of the device, however, in dynamic partition devices the size of the partitions belonging to `SUPER` is relative and can expand during installation. Enabling forced installation is useful to proceed with the installation anyway.
>
> **7.** Indicates that the use of `Recovery` should always be preferred for flashing `ZIP` files. Remembering that the Tool also supports flashing these files with the device booted.
>
> **8.** Enable all file extensions in the file selector.
>
> **9.** Indicates that a step-by-step trace of each line of a `Config Script` should be shown. This is useful to check the flow.


>
> <p align="center"> <img src="https://raw.githubusercontent.com/BlassGO/AutoIMG_Doc/main/images/tool4.png"></p>
> 
> **1.** IP for wireless connection.
> 
> **2.** PORT for wireless connection.
> 
> **3.** Start wireless connection.
>
> **4.** Disable wireless connection. This returns to a normal search for USB devices.