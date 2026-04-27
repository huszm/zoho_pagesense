import Flutter
import UIKit
#if !targetEnvironment(simulator)
import PageSenseFramework
#endif

public class ZohoPagesensePlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "zoho_pagesense",
            binaryMessenger: registrar.messenger()
        )
        let instance = ZohoPagesensePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "init":
            handleInit(call: call, result: result)
        case "setUserId":
            handleSetUserId(call: call, result: result)
        case "setTrackingEnabled", "clearAllData":
            // Phase 5
            result(FlutterMethodNotImplemented)
        case "trackEvent", "trackScreen", "trackPurchase":
            // Phase 3
            result(FlutterMethodNotImplemented)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleInit(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
            let args = call.arguments as? [String: Any],
            let appId = args["appId"] as? String,
            !appId.isEmpty
        else {
            result(FlutterError(code: "INVALID_APP_ID", message: "appId must not be empty.", details: nil))
            return
        }
        #if !targetEnvironment(simulator)
        PageSense.initWith(appId: appId)
        #endif
        result(nil)
    }

    private func handleSetUserId(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        let userId = args?["userId"] as? String
        #if !targetEnvironment(simulator)
        var profile: [String: String] = [:]
        if let uid = userId {
            profile["email"] = uid
        }
        PageSense.trackUser(userProfile: profile)
        #endif
        result(nil)
    }
}
