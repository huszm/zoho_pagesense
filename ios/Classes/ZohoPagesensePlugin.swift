import Flutter
import UIKit
import PageSenseFramework
import ObjectiveC.runtime

// MARK: - Hex → Data helper

private extension String {
    func hexToData() -> Data? {
        let hex = self.replacingOccurrences(of: " ", with: "")
        guard hex.count % 2 == 0 else { return nil }
        var data = Data(capacity: hex.count / 2)
        var index = hex.startIndex
        while index < hex.endIndex {
            let next = hex.index(index, offsetBy: 2)
            guard let byte = UInt8(hex[index..<next], radix: 16) else { return nil }
            data.append(byte)
            index = next
        }
        return data
    }
}

// MARK: - Bundle injection

// After method_exchangeImplementations the "infoDictionary" selector runs our
// code below, and "ps_infoDictionary" runs the original implementation.
// @objc dynamic forces ObjC message dispatch so the recursive call inside
// ps_infoDictionary correctly reaches the swapped-in original, not itself.
extension Bundle {
    @objc dynamic func ps_infoDictionary() -> [String: Any]? {
        guard var dict = self.ps_infoDictionary() else { return nil }
        if self === Bundle.main {
            if let injected = PageSenseBundleInjector.appId {
                dict["ZPS_APP_ID"] = injected
            }
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
            let original    = class_getInstanceMethod(cls, NSSelectorFromString("infoDictionary")),
            let replacement = class_getInstanceMethod(cls, #selector(Bundle.ps_infoDictionary))
        else { return }
        method_exchangeImplementations(original, replacement)
    }
}

// MARK: - Plugin

private let kAPNSTokenKey = "ps_apns_token"

public class ZohoPagesensePlugin: NSObject, FlutterPlugin {

    /// True after PageSense.integrate() has been called.
    /// AppDelegate reads this to decide whether to call PageSense.setPushToken immediately.
    public private(set) static var isIntegrated = false

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
            handleSetPushToken(call: call, result: result)
        case "isPageSensePushNotification":
            result(false) // handled natively in AppDelegate on iOS
        case "showPushNotification":
            result(nil)   // handled natively in AppDelegate on iOS
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
        // Inject appId into Bundle.main.infoDictionary so integrate() picks it up
        // regardless of whether Info.plist contains the key.
        PageSenseBundleInjector.install(appId: appId)
        PageSense.integrate()
        ZohoPagesensePlugin.isIntegrated = true
        // Register the APNs token that AppDelegate stored before init completed.
        if let token = UserDefaults.standard.data(forKey: kAPNSTokenKey) {
            PageSense.setPushToken(deviceToken: token)
        }
        result(nil)
    }

    // MARK: - Push notifications

    private func handleSetPushToken(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard
            let args = call.arguments as? [String: Any],
            let tokenHex = args["token"] as? String,
            !tokenHex.isEmpty
        else {
            result(FlutterError(code: "INVALID_ARGS", message: "token is required", details: nil))
            return
        }
        guard let tokenData = tokenHex.hexToData() else {
            result(FlutterError(code: "INVALID_TOKEN", message: "token must be a valid hex string", details: nil))
            return
        }
        PageSense.setPushToken(deviceToken: tokenData)
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
