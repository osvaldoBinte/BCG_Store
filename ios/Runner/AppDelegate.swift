import Flutter
import UIKit
import Photos

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let photoPermissionChannel = FlutterMethodChannel(name: "com.bgcstore.photoPermission", 
                                                    binaryMessenger: controller.binaryMessenger)
    
    photoPermissionChannel.setMethodCallHandler { (call, result) in
      if call.method == "requestPhotoAccess" {
        self.requestPhotoLibraryPermission(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func requestPhotoLibraryPermission(result: @escaping FlutterResult) {
    let status = PHPhotoLibrary.authorizationStatus()
    
    switch status {
    case .authorized:
      result(true)
      return
    case .denied, .restricted:
      result(false)
      return
    case .notDetermined:
      // Esta es la línea clave que mostrará el diálogo de permiso
      PHPhotoLibrary.requestAuthorization { newStatus in
        DispatchQueue.main.async {
          result(newStatus == .authorized)
        }
      }
      return
    @unknown default:
      // Para iOS 14+ podemos comprobar si es .limited de manera segura
      if #available(iOS 14, *) {
        if status == .limited {
          result(true)
          return
        }
      }
      result(false)
    }
  }
}