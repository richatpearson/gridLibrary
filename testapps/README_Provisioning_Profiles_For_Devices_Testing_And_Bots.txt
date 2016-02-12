
README

For the client apps there are some important Provisioning Profile and Code Signing configurations that must be used.

FOR THE BOTS
------------
To get the client apps to build .ipa files for the OSX Server, Xcode Server, you must use the following Provisioning Profile (under Build Settings / Code Signing):  NCS Ad Hoc Wildcard Distribution.  The Code Signing Identity must be:  iPhone Distribution:  NCS Pearson Inc. in all the places in Code Signing.  These setting must exist in both the PROJECT, and in the TARGET.  Always default to this setting when you commit your code.

FOR THE DEVELOPER TO TEST ON DEVICES
-------------------------------------
To get the client apps to run on the developer device, you must use the following Provisioning Profile (under Build Settings / Code Signing):  NCS Team Dev Profile.  The Code Signing Identity must be:  Automatic, in all the places in Code Signing.  These setting must exist in both the PROJECT, and in the TARGET.  

WHEN YOU COMMIT TO STASH
------------------------
Make sure to change the Provisioning Profile, and Code Signing configurations to the:  FOR THE BOTS.




