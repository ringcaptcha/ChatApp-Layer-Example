# ChatApp with Layer Example

This repository contains an example project that includes the basics on how to implement a Chat application on iOS with messaging services provided by [Layer](https://layer.com), user interface components from [Atlas](https://github.com/layerhq/Atlas-iOS) and phone-based authentication service and two-step verification UI provided by [RingCaptcha](http://ringcaptcha.com).

## Requirements

This application requires Xcode and the iOS SDK v8.0. Dependencies are managed via [CocoaPods](http://cocoapods.org/) to simplify installation.

## Setup

1. Clone the project from Github: `$ git clone https://github.com/ringcaptcha/ChatApp-Layer-Example.git`
2. Install the dependencies in the root directory via CocoaPods: `$ pod install`
3. Open `ChatApp.xcworkspace` in Xcode.
4. Add a plist file named `Secrets.plist` under `Resources` with your `RingCaptchaAppKey` , `RingCaptchaSecretKey` , `LayerAppId`, and `AuthenticationURL`.
5. Build and run the application on your Simulator and begin messaging!

## Highlights

* Uses [RingCaptcha](https://github.com/ringcaptcha/ringcaptcha-ios) to perform two-step phone based authenticate to users.
* Uses [Atlas](https://atlas.layer.com), Layer's UI components
* Uses [LayerKit](https://layer.com) for messaging

## License

This project is available under the Apache 2 License. See the LICENSE file for more info.