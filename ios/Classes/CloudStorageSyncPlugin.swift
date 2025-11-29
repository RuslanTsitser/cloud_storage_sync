import Flutter
import UIKit

public class CloudStorageSyncPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "cloud_storage_sync", binaryMessenger: registrar.messenger())
    let instance = CloudStorageSyncPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isCloudStorageAvailable":
      result(ICloudService.isICloudAvailable())
    case "getDocumentsDirectoryPath":
      if let url = ICloudService.getDocumentsDirectoryURL() {
        result(url.path)
      } else {
        result(nil)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
