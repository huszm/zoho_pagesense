import Flutter
import UIKit
import PageSenseFramework

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
        case "init":            handleInit(call: call, result: result)
        case "setUserId":       handleSetUserId(call: call, result: result)
        case "trackEvent":      handleTrackEvent(call: call, result: result)
        case "trackScreen":     handleTrackScreen(call: call, result: result)
        case "trackPurchase":   handleTrackPurchase(call: call, result: result)
        case "setTrackingEnabled", "clearAllData":
            result(nil) // Underlying SDK has no opt-out / data-deletion API.
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Init

    private func handleInit(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
            let args = call.arguments as? [String: Any],
            let appId = args["appId"] as? String,
            !appId.isEmpty
        else {
            result(FlutterError(code: "INVALID_APP_ID", message: "appId must not be empty.", details: nil))
            return
        }
        // Attempt to inject appId via UserDefaults before integrate() in case
        // the SDK reads it from there as a fallback to Info.plist "appID" key.
        UserDefaults.standard.set(appId, forKey: "appID")
        UserDefaults.standard.synchronize()
        PageSense.integrate()
        result(nil)
    }

    // MARK: - User

    private func handleSetUserId(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        let userId = args?["userId"] as? String
        var profile: [String: String] = [:]
        if let uid = userId { profile["email"] = uid }
        PageSense.trackUser(userProfile: profile)
        result(nil)
    }

    // MARK: - Events

    private func handleTrackEvent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
            let args = call.arguments as? [String: Any],
            let name = args["name"] as? String
        else {
            result(FlutterError(code: "INVALID_ARGS", message: "name is required", details: nil))
            return
        }
        if let rawProps = args["properties"] as? [String: Any] {
            PageSense.trackEvent(eventName: name, withProperties: rawProps.mapValues { "\($0)" })
        } else {
            PageSense.trackEvent(eventName: name)
        }
        result(nil)
    }

    private func handleTrackScreen(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
            let args = call.arguments as? [String: Any],
            let name = args["name"] as? String
        else {
            result(FlutterError(code: "INVALID_ARGS", message: "name is required", details: nil))
            return
        }
        var props: [String: String] = ["screen_name": name]
        if let rawProps = args["properties"] as? [String: Any] {
            rawProps.forEach { props[$0.key] = "\($0.value)" }
        }
        PageSense.trackEvent(eventName: "screen_view", withProperties: props)
        result(nil)
    }

    private func handleTrackPurchase(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "arguments required", details: nil))
            return
        }
        let amount    = args["amount"]    as? Double ?? 0.0
        let currency  = args["currency"]  as? String ?? ""
        let productId = args["productId"] as? String
        var props: [String: String] = ["amount": String(amount), "currency": currency]
        if let pid = productId { props["productId"] = pid }
        PageSense.trackEvent(eventName: "purchase", withProperties: props)
        result(nil)
    }
}
