# QR-Tech-Client

:warning: **IMPORTANT NOTE**: This application is still **in development** and should **not** be used for its intended purpose until a stable version is released.

This application has only been tested in **Android 10** systems and above.

---

<p align="center">
  <img src="/assets/logo-2.png" width="400"/>
</p>

## About this application

This application is to be used in combination with the web-client application **[Android-QR-System](https://github.com/logesixas96/Android-QR-System)**.  

The goal of this application is to allow an user to create an event inputting data such as time, date, and location to generate a unique qr-code that attendees, of the said event, can log their attendance.

---

## Compile From Source

In the event that the you would like to compile and package the program yourselves, perform the following steps.

### Install Flutter

#### Linux

```bash
# Install Flutter SDK and other dependencies
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev  
sudo snap install flutter --classic
flutter channel stable  # run this and below command if flutter was installed previously
flutter upgrade

# Pull code from repo and build
git clone https://github.com/logesixas96/QR-Tech-Client
cd QR-Tech-Client/
flutter build apk  
```

#### Windows

Ensure [Windows Powershell 5.0](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-windows-powershell) and the latest version of [Git](https://git-scm.com/download/win) is installed.

```powershell
# run in powershell to install Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
```

If you wish to use flutter in the console, follow the steps [here](https://docs.flutter.dev/get-started/install/windows#update-your-path). We can now begin  cloning the repository and building the application.  

```powershell
git clone https://github.com/logesixas96/QR-Tech-Client
cd QR-Tech-Client/
flutter build apk  
```

---

**Important Note**: This program is licenced under GNU GPLv2

**side note**: This application was created as a project during our ([logesixas96](https://github.com/logesixas96) and [kshorenicholas](https://github.com/kshorenicholas)) internship. Future maintanence of these two repositories are yet to be decided.
