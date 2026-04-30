package com.appsbunches.zoho_pagesense

import android.app.Application
import com.zoho.pagesense.android.PSNotification
import com.zoho.pagesense.android.PageSense
import com.zoho.pagesense.android.eventtracking.UserInfo
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import android.app.Activity

class ZohoPagesensePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var application: Application? = null
    private var activity: Activity? = null

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        application = binding.applicationContext as? Application
        channel = MethodChannel(binding.binaryMessenger, "zoho_pagesense")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "init"               -> handleInit(call, result)
            "setUserId"          -> handleSetUserId(call, result)
            "setUserInfo"        -> handleSetUserInfo(call, result)
            "trackEvent"         -> handleTrackEvent(call, result)
            "trackScreen"        -> handleTrackScreen(call, result)
            "trackPurchase"      -> handleTrackPurchase(call, result)
            "setTrackingEnabled"          -> result.success(null)
            "clearAllData"               -> result.success(null)
            "setPushToken"               -> handleSetPushToken(call, result)
            "isPageSensePushNotification" -> handleIsPageSensePush(call, result)
            "showPushNotification"        -> handleShowPushNotification(call, result)
            else                          -> result.notImplemented()
        }
    }

    private fun handleInit(call: MethodCall, result: Result) {
        val appId = call.argument<String>("appId")
        if (appId.isNullOrBlank()) {
            result.error("INVALID_APP_ID", "appId must not be empty.", null)
            return
        }
        try {
            val app = application
            if (app != null) {
                PageSense.init(app, appId)
                
                // Trigger lifecycle events for the current activity since PageSense 
                // was initialized after the activity was already created and resumed.
                val act = activity
                if (act != null) {
                    val callbacks = PageSense.activityLifecycleCallbacks
                    callbacks?.onActivityCreated(act, null)
                    callbacks?.onActivityStarted(act)
                    callbacks?.onActivityResumed(act)
                }
            }
            result.success(null)
        } catch (e: Exception) {
            result.error("INIT_FAILED", e.message, null)
        }
    }

    private fun handleSetUserId(call: MethodCall, result: Result) {
        val userId = call.argument<String?>("userId")
        try {
            UserInfo.setEmail(userId)
            PageSense.addUserInfo()
            result.success(null)
        } catch (e: Exception) {
            result.error("SET_USER_FAILED", e.message, null)
        }
    }

    private fun handleSetUserInfo(call: MethodCall, result: Result) {
        try {
            call.argument<String?>("name")?.let  { UserInfo.setFirstname(it) }
            call.argument<String?>("email")?.let { UserInfo.setEmail(it) }
            call.argument<String?>("phone")?.let { UserInfo.setPhone(it) }
            val pushOptIn = call.argument<Boolean>("pushOptIn") ?: true
            UserInfo.setPushOptIn(pushOptIn)
            PageSense.addUserInfo()
            result.success(null)
        } catch (e: Exception) {
            result.error("SET_USER_INFO_FAILED", e.message, null)
        }
    }

    private fun handleTrackEvent(call: MethodCall, result: Result) {
        val name = call.argument<String>("name")
        if (name.isNullOrBlank()) {
            result.error("INVALID_ARGS", "name is required", null)
            return
        }
        try {
            @Suppress("UNCHECKED_CAST")
            val properties = call.argument<Map<String, Any>>("properties")
            PageSense.addEvent(name, HashMap<String?, Any?>(properties ?: emptyMap()))
            result.success(null)
        } catch (e: Exception) {
            result.error("TRACK_EVENT_FAILED", e.message, null)
        }
    }

    private fun handleTrackScreen(call: MethodCall, result: Result) {
        val name = call.argument<String>("name")
        if (name.isNullOrBlank()) {
            result.error("INVALID_ARGS", "name is required", null)
            return
        }
        try {
            @Suppress("UNCHECKED_CAST")
            val properties = call.argument<Map<String, Any>>("properties")
            val props = HashMap<String?, Any?>(properties ?: emptyMap())
            props["screen_name"] = name
            PageSense.addEvent("screen_view", props)
            result.success(null)
        } catch (e: Exception) {
            result.error("TRACK_SCREEN_FAILED", e.message, null)
        }
    }

    private fun handleTrackPurchase(call: MethodCall, result: Result) {
        val amount   = call.argument<Double>("amount") ?: 0.0
        val currency = call.argument<String>("currency") ?: ""
        val productId = call.argument<String?>("productId")
        try {
            // trackRevenue expects an integer amount in minor units (cents).
            PageSense.trackRevenue((amount * 100).toInt())
            val props = hashMapOf<String?, Any?>("amount" to amount, "currency" to currency)
            if (productId != null) props["productId"] = productId
            PageSense.addEvent("purchase", props)
            result.success(null)
        } catch (e: Exception) {
            result.error("TRACK_PURCHASE_FAILED", e.message, null)
        }
    }

    private fun handleSetPushToken(call: MethodCall, result: Result) {
        val token = call.argument<String>("token")
        if (token.isNullOrBlank()) {
            result.error("INVALID_ARGS", "token is required", null)
            return
        }
        try {
            PSNotification.sendDeviceToken(token)
            result.success(null)
        } catch (e: Exception) {
            result.error("SET_PUSH_TOKEN_FAILED", e.message, null)
        }
    }

    private fun handleIsPageSensePush(call: MethodCall, result: Result) {
        @Suppress("UNCHECKED_CAST")
        val data = call.argument<Map<String, String>>("data") ?: emptyMap()
        try {
            result.success(PSNotification.isFromPageSensePlatform(HashMap(data)))
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun handleShowPushNotification(call: MethodCall, result: Result) {
        @Suppress("UNCHECKED_CAST")
        val data = call.argument<Map<String, String>>("data") ?: emptyMap()
        try {
            // Zoho SDK's showNotification expects (Map<String, String>, Int iconResourceId)
            // It does NOT take a notification ID. We must pass a valid drawable resource.
            val iconResId = application?.applicationInfo?.icon ?: android.R.drawable.sym_def_app_icon
            PSNotification.showNotification(HashMap(data), iconResId)
            result.success(null)
        } catch (e: Exception) {
            result.error("SHOW_NOTIFICATION_FAILED", e.message, null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        application = null
    }
}
