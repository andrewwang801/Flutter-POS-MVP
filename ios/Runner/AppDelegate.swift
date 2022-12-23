import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    //let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    //let orientationChannel = FlutterMethodChannel(name: "samples.flutter.dev/orientation",
                                              //binaryMessenger: controller.binaryMessenger)
    /*orientationChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      // This method is invoked on the UI thread.
        guard call.method == "setOrientation" else {
          result(FlutterMethodNotImplemented)
          return
        }
        self.setOrientation(result: result)
    })*/
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    /*private func setOrientation(result: FlutterResult) {
        if (UIDevice.current.orientation.rawValue == UIInterfaceOrientation.landscapeRight.rawValue || UIDevice.current.orientation.rawValue == UIInterfaceOrientation.landscapeLeft.rawValue) {
            
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
        else {
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }*/
}
