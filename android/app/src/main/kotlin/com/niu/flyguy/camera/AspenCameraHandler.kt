package com.niu.flyguy.camera

import android.app.Activity
import android.util.Log
import com.jovision.jvplayer.callback.JVSRequestCallback
import com.jovision.jvplayer.data.response.EmptyBean
import com.jovision.jvplayer.player.JVPlayerUtil
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Aspen 摄像头通信处理器
 *
 * 职责：
 * 1. MethodChannel: 处理 Flutter 的控制调用（play, pause, dispose 等）
 * 2. EventChannel: 推送播放器状态事件到 Flutter
 */
class AspenCameraHandler(
    private val flutterEngine: FlutterEngine,
    private val activity: Activity
) {
    companion object {
        private const val TAG = "AspenCameraHandler"

        // MethodChannel: Flutter 调用 Android
        private const val METHOD_CHANNEL_NAME = "camera/aspen"

        // EventChannel: Android 推送事件到 Flutter
        private const val EVENT_CHANNEL_NAME = "camera/aspen/events"
    }

    // ═══════════════════════════════════════════════════════════════
    // MethodChannel - Flutter 调用 Android 的控制方法
    // ═══════════════════════════════════════════════════════════════
    private val methodChannel: MethodChannel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        METHOD_CHANNEL_NAME
    )

    // ═══════════════════════════════════════════════════════════════
    // EventChannel - Android 主动推送事件到 Flutter
    // ═══════════════════════════════════════════════════════════════
    private val eventChannel: EventChannel = EventChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        EVENT_CHANNEL_NAME
    )

    // EventChannel 的事件发送器（Flutter 监听时会设置）
    private var eventSink: EventChannel.EventSink? = null

    private var isPlayerInitialized = false

    fun register() {
        Log.d(TAG, "注册通信通道")

        // ─────────────────────────────────────────────────────────
        // 注册 MethodChannel（处理 Flutter 的方法调用）
        // ─────────────────────────────────────────────────────────
        methodChannel.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "initialize" -> handleInitialize(call, result)
                    "play" -> handlePlay(result)
                    "pause" -> handlePause(result)
                    "dispose" -> handleDispose(result)
                    "takeSnapshot" -> handleSnapshot(result)
                    "switchQuality" -> handleSwitchQuality(call, result)
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                Log.e(TAG, "MethodChannel 方法调用异常: ${call.method}", e)
                result.error("EXCEPTION", e.message, e.stackTraceToString())
            }
        }

        // ─────────────────────────────────────────────────────────
        // 注册 EventChannel（监听 Flutter 的订阅）
        // ─────────────────────────────────────────────────────────
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            // Flutter 开始监听时调用
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                Log.d(TAG, "EventChannel: Flutter 开始监听播放器事件")
                eventSink = events
            }

            // Flutter 停止监听时调用
            override fun onCancel(arguments: Any?) {
                Log.d(TAG, "EventChannel: Flutter 停止监听播放器事件")
                eventSink = null
            }
        })

        Log.d(TAG, "通信通道注册完成")
    }

    // ═══════════════════════════════════════════════════════════════
    // EventChannel - 发送事件到 Flutter 的公共方法
    // ═══════════════════════════════════════════════════════════════

    /**
     * 发送播放器事件到 Flutter
     *
     * @param event 事件数据（Map 格式）
     *
     * 示例：
     * sendPlayerEvent(mapOf(
     *     "type" to "player",
     *     "event" to "video_ready"
     * ))
     */
    fun sendPlayerEvent(event: Map<String, Any>) {
        activity.runOnUiThread {
            eventSink?.success(event)
            Log.d(TAG, "EventChannel: 发送事件到 Flutter: $event")
        }
    }

    /**
     * 发送错误到 Flutter
     *
     * @param code 错误代码
     * @param message 错误消息
     * @param details 详细信息（可选）
     */
    fun sendPlayerError(code: String, message: String?, details: Any? = null) {
        activity.runOnUiThread {
            eventSink?.error(code, message, details)
            Log.e(TAG, "EventChannel: 发送错误到 Flutter: $code - $message")
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MethodChannel - 处理 Flutter 的方法调用
    // ═══════════════════════════════════════════════════════════════

    private fun handleInitialize(call: MethodCall, result: MethodChannel.Result) {
        val deviceId = call.argument<String>("deviceId")
        Log.d(TAG, "MethodChannel: 初始化播放器: deviceId=$deviceId")

        if (deviceId.isNullOrEmpty()) {
            result.error("INVALID_PARAMETER", "deviceId 不能为空", null)
            return
        }

        try {
            isPlayerInitialized = true
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "MethodChannel: 初始化失败", e)
            result.error("INIT_ERROR", e.message, e.stackTraceToString())
        }
    }

    private fun handlePlay(result: MethodChannel.Result) {
        Log.d(TAG, "MethodChannel: 开始播放")
        try {
            JVPlayerUtil.instance.initP2P()
            JVPlayerUtil.instance.onResume()
            JVPlayerUtil.instance.startPlayer()
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "MethodChannel: 播放失败", e)
            result.error("PLAY_ERROR", e.message, e.stackTraceToString())
        }
    }

    private fun handlePause(result: MethodChannel.Result) {
        Log.d(TAG, "MethodChannel: 暂停播放")
        try {
            JVPlayerUtil.instance.stopPlayer()
            JVPlayerUtil.instance.onDestroy()
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "MethodChannel: 暂停失败", e)
            result.error("PAUSE_ERROR", e.message, e.stackTraceToString())
        }
    }

    private fun handleDispose(result: MethodChannel.Result) {
        Log.d(TAG, "MethodChannel: 释放播放器资源")
        try {
            JVPlayerUtil.instance.stopPlayer()
            JVPlayerUtil.instance.onDestroy()
            isPlayerInitialized = false
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "MethodChannel: 资源释放失败", e)
            result.error("DISPOSE_ERROR", e.message, e.stackTraceToString())
        }
    }

    private fun handleSnapshot(result: MethodChannel.Result) {
        Log.d(TAG, "MethodChannel: 截图")
        try {
            val fileName = "snapshot_${System.currentTimeMillis()}.jpg"
            val filePath = activity.getExternalFilesDir("Pictures")?.absolutePath + "/$fileName"
            JVPlayerUtil.instance.startSnapshot(1, filePath)
            result.success(filePath)
        } catch (e: Exception) {
            Log.e(TAG, "MethodChannel: 截图失败", e)
            result.error("SNAPSHOT_ERROR", e.message, e.stackTraceToString())
        }
    }

    private fun handleSwitchQuality(call: MethodCall, result: MethodChannel.Result) {
        val quality = call.argument<String>("quality")
        Log.d(TAG, "MethodChannel: 切换清晰度: $quality")

        try {
            val streamType = if (quality == "low") 1 else 0
            JVPlayerUtil.instance.switchStreamType(streamType, object : JVSRequestCallback<EmptyBean> {
                override fun onSuccess(emptyBean: EmptyBean) {
                    result.success(null)
                }

                override fun onFailure(code: Int) {
                    result.error("QUALITY_ERROR", "切换失败: $code", null)
                }
            })
        } catch (e: Exception) {
            result.error("QUALITY_ERROR", e.message, e.stackTraceToString())
        }
    }

    fun unregister() {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }
}
