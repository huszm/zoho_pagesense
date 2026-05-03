import Flutter
import UIKit
import PageSenseFramework

// On iOS the host app is responsible for:
//   1. Adding ZPS_APP_ID to Info.plist
//   2. Calling PageSense.integrate() in AppDelegate.didFinishLaunchingWithOptions
//   3. Calling PageSense.setPushToken(deviceToken:) in
//      AppDelegate.didRegisterForRemoteNotificationsWithDeviceToken
//
// This plugin therefore only bridges Dart calls for events / user / screen
// tracking. iOS init and push token registration are no-ops here.
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
            // PageSense.integrate() is called by the host AppDelegate using
            // the static ZPS_APP_ID from Info.plist.
            result(nil)
        case "setUserId":       handleSetUserId(call: call, result: result)
        case "setUserInfo":     handleSetUserInfo(call: call, result: result)
        case "trackEvent":      handleTrackEvent(call: call, result: result)
        case "trackScreen":     handleTrackScreen(call: call, result: result)
        case "trackPurchase":   handleTrackPurchase(call: call, result: result)
        case "setTrackingEnabled", "clearAllData":
            result(nil)
        case "setPushToken":
            // Token registration is done by the host AppDelegate with the raw
            // APNs Data bytes. The Dart-side hex string would be lossy here.
            result(nil)
        case "isPageSensePushNotification":
            // iOS notifications are delivered through APNs, not FCM data.
            result(false)
        case "showPushNotification":
            // iOS displays notifications natively; nothing to render here.
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
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

    private func handleSetUserInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]
        var profile: [String: String] = [:]
        if let name  = args["name"]  as? String { profile["firstname"] = name }
        if let email = args["email"] as? String { profile["email"]     = email }
        if let phone = args["phone"] as? String { profile["phone"]     = phone }
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
