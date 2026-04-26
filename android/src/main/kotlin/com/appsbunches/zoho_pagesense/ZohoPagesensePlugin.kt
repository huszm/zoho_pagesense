package com.appsbunches.zoho_pagesense

import android.app.Application
import com.zoho.pagesense.PageSense
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
            "init" -> handleInit(call, result)
            "setUserId" -> handleSetUserId(call, result)
            "setTrackingEnabled" -> handleSetTrackingEnabled(call, result)
            "clearAllData" -> handleClearAllData(result)
            // Phase 3
            "trackEvent", "trackScreen", "trackPurchase" ->
                result.notImplemented()
            else -> result.notImplemented()
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
                // dataCenter is encoded in appId by Zoho dashboard; pass raw.
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

    private fun handleSetTrackingEnabled(call: MethodCall, result: Result) {
        // Phase 5 — native SDK API TBD.
        result.notImplemented()
    }

    private fun handleClearAllData(result: Result) {
        // Phase 5 — native SDK API TBD.
        result.notImplemented()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        application = null
    }
}
