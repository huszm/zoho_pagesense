package com.appsbunches.zoho_pagesense

import android.app.Application
import com.zoho.pagesense.android.PageSense
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class ZohoPagesensePlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private var application: Application? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        application = binding.applicationContext as? Application
        channel = MethodChannel(binding.binaryMessenger, "zoho_pagesense")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "init"               -> handleInit(call, result)
            "setUserId"          -> handleSetUserId(call, result)
            "trackEvent"         -> handleTrackEvent(call, result)
            "trackScreen"        -> handleTrackScreen(call, result)
            "trackPurchase"      -> handleTrackPurchase(call, result)
            "setTrackingEnabled" -> result.success(null) // SDK has no opt-out API
            "clearAllData"       -> result.success(null) // SDK has no data-deletion API
            else                 -> result.notImplemented()
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
            }
            result.success(null)
        } catch (e: Exception) {
            result.error("INIT_FAILED", e.message, null)
        }
    }

    private fun handleSetUserId(call: MethodCall, result: Result) {
        val userId = call.argument<String?>("userId")
        try {
            val userInfo = PageSense.getUserInfoInstance()
            userInfo?.setEmail(userId)
            PageSense.addUserInfo()
            result.success(null)
        } catch (e: Exception) {
            result.error("SET_USER_FAILED", e.message, null)
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
            PageSense.addEvent(name, HashMap(properties ?: emptyMap()))
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
            val props = HashMap<String, Any>(properties ?: emptyMap())
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
            val props = hashMapOf<String, Any>("amount" to amount, "currency" to currency)
            if (productId != null) props["productId"] = productId
            PageSense.addEvent("purchase", props)
            result.success(null)
        } catch (e: Exception) {
            result.error("TRACK_PURCHASE_FAILED", e.message, null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        application = null
    }
}
