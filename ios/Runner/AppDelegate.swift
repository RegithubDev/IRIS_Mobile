import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
        if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
      }
      let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
          let rootChannel = FlutterMethodChannel(name: "root", binaryMessenger: controller.binaryMessenger)
          
          rootChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if (call.method == "isRooted") {
              // Implement the actual logic to check if the device is rooted/jailbroken
              // This is just a placeholder for the example
              result(false)
            } else {
              result(FlutterMethodNotImplemented)
            }
          }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
