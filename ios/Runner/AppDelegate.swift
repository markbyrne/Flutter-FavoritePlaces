import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Load API key from Secrets.plist
    if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
      let secrets = NSDictionary(contentsOfFile: path),
      let apiKey = secrets["GoogleMapsAPIKey"] as? String
    {
      GMSServices.provideAPIKey(apiKey)
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
