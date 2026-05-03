import Flutter
import UIKit
import PageSenseFramework
import ObjectiveC.runtime

// MARK: - Bundle injection
//
// PageSense.integrate() reads the App ID from Bundle.main.infoDictionary["ZPS_APP_ID"].
// Hosts that fetch the App ID dynamically (from a server) can't put it in Info.plist
// at build time, so we swizzle Bundle.infoDictionary to inject the value at runtime.
// After method_exchangeImplementations the "infoDictionary" selector runs the code
// below, and "ps_infoDictionary" runs the original implementation.
extension Bundle {
    @objc dynamic func ps_infoDictionary() -> [String: Any]? {
        guard var dict = self.ps_infoDictionary() else { return nil }
        if self === Bundle.main, let injected = PageSenseBundleInjector.appId {
            dict["ZPS_APP_ID"] = injected
        }
        return dict
    }
}

private enum PageSenseBundleInjector {
    static var appId: String?
    private static var installed = false
    private static let lock = NSLock()

    static func install(appId: String) {
        lock.lock()
        defer { lock.unlock() }
        self.appId = appId
        guard !installed else { return }
        installed = true
        let cls: AnyClass = Bundle.self
        guard
            let original = class_getInstanceMethod(cls, NSSelectorFromString("infoDictionary")),
            let replacement = class_getInstanceMethod(cls, #selector(Bundle.ps_infoDictionary))
        else { return }
        method_exchangeImplementations(original, replacement)
    }
}

// MARK: - Plugin

private let kAPNSTokenKey = "ps_apns_token"

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
        case "setUserInfo":     handleSetUserInfo(call: call, result: result)
        case "trackEvent":      handleTrackEvent(call: call, result: result)
        case "trackScreen":     handleTrackScreen(call: call, result: result)
        case "trackPurchase":   handleTrackPurchase(call: call, result: result)
        case "setTrackingEnabled", "clearAllData":
            result(nil)
        case "setPushToken":
            // Token registration is done by the host AppDelegate with the raw
            // APNs Data bytes (via UserDefaults). The Dart hex string would be lossy.
            result(nil)
        case "isPageSensePushNotification":
            result(false) // iOS uses APNs, not FCM data messages
        case "showPushNotification":
            result(nil)   // iOS displays notifications natively
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
        // Inject appId so PageSense.integrate() finds it in Bundle.main.infoDictionary.
        PageSenseBundleInjector.install(appId: appId)
        PageSense.integrate()
        // Flush the raw APNs token AppDelegate captured before integrate() was called.
        if let token = UserDefaults.standard.data(forKey: kAPNSTokenKey) {
            PageSense.setPushToken(deviceToken: token)
        }
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
