// Copyright 2022-present 650 Industries. All rights reserved.

import AppTrackingTransparency
import ABI46_0_0ExpoModulesCore

public class TrackingTransparencyPermissionRequester: NSObject, ABI46_0_0EXPermissionsRequester {
  static public func permissionType() -> String {
    return "appTracking"
  }

  public func requestPermissions(resolver resolve: @escaping ABI46_0_0EXPromiseResolveBlock, rejecter reject: ABI46_0_0EXPromiseRejectBlock) {
    if #available(iOS 14, *) {
      ATTrackingManager.requestTrackingAuthorization() { [weak self] _ in
        resolve(self?.getPermissions());
      }
    } else {
      resolve(self.getPermissions());
    }
  }

  public func getPermissions() -> [AnyHashable: Any] {
    var status: ABI46_0_0EXPermissionStatus
    
    if #available(iOS 14, *) {
      var systemStatus: ATTrackingManager.AuthorizationStatus
      
      let trackingUsageDescription = Bundle.main.object(forInfoDictionaryKey: "NSUserTrackingUsageDescription")
      if trackingUsageDescription == nil {
        ABI46_0_0EXFatal(ABI46_0_0EXErrorWithMessage("""
        This app is missing 'NSUserTrackingUsageDescription' so tracking transparency will fail. \
        Ensure that this key exists in app's Info.plist.
        """))
        systemStatus = .denied
      } else {
        systemStatus = ATTrackingManager.trackingAuthorizationStatus
      }

      switch systemStatus {
      case .authorized:
        status = ABI46_0_0EXPermissionStatusGranted
      case .restricted,
           .denied:
        status = ABI46_0_0EXPermissionStatusDenied
      case .notDetermined:
        fallthrough
      @unknown default:
        status = ABI46_0_0EXPermissionStatusUndetermined
      }
    } else {
      status = ABI46_0_0EXPermissionStatusGranted
    }

    return [
      "status": status.rawValue
    ]
  }
}
