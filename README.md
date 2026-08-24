

# How to run emulator
To run android emulator
"& "C:\Users\srikr\AppData\Local\Android\sdk\emulator\emulator.exe" -avd Pixel_6_API_35 -gpu swiftshader"

To use web camera
& "C:\Users\srikr\AppData\Local\Android\sdk\emulator\emulator.exe" -avd Pixel_6_API_35 -gpu swiftshader -camera-front webcam0 -no-snapshot-load -selinux disabled

To get adb devices
"& "C:\Users\srikr\AppData\Local\Android\sdk\platform-tools\adb.exe" devices"

Order
"& "C:\Users\srikr\AppData\Local\Android\sdk\emulator\emulator.exe" -avd Pixel_6_API_35 -gpu swiftshader -camera-front webcam0"
"flutter run -d emulator-5554"

& "C:\Users\srikr\AppData\Local\Android\sdk\emulator\emulator.exe" -avd Pixel_6_API_35 -gpu swiftshader -camera-front webcam0 -no-snapshot-load (if issues use this)

pull manifest and auth log using adb
& "C:\Users\srikr\AppData\Local\Android\sdk\platform-tools\adb.exe" shell cat /sdcard/Download/authentication_log.txt
& "C:\Users\srikr\AppData\Local\Android\sdk\platform-tools\adb.exe" shell cat /sdcard/Download/ransomware_manifest.txt

To read the ransom_manifest.txt and authentication_log.txt
& "C:\Users\srikr\AppData\Local\Android\sdk\platform-tools\adb.exe" shell cat /sdcard/Download/ransomware_manifest.txt
& "C:\Users\srikr\AppData\Local\Android\sdk\platform-tools\adb.exe" shell cat /sdcard/Download/authentication_log.txt