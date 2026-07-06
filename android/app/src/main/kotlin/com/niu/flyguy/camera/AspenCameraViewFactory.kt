package com.niu.flyguy.camera

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.SurfaceView
import android.view.View
import com.jovision.jvplayer.player.JVPlayerCallback
import com.jovision.jvplayer.player.JVPlayerUtil
import com.jovision.jvplayer.player.PlayEventCode
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Aspen 摄像头 PlatformView 工厂
 *
 * 职责：创建 AspenCameraView 实例
 */
class AspenCameraViewFactory(
    private val activity: Activity,
    private val eventHandler: AspenCameraHandler  // 接收 Handler，用于发送事件到 Flutter
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    companion object {
        private const val TAG = "AspenCameraViewFactory"
    }

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<*, *> ?: emptyMap<String, Any>()
        Log.d(TAG, "创建 PlatformView: viewId=$viewId, params=$params")
        // 传递 eventHandler 给 View
        return AspenCameraView(activity, viewId, params, eventHandler)
    }
}

/**
 * Aspen 摄像头视图
 */
class AspenCameraView(
    private val activity: Activity,
    private val viewId: Int,
    private val params: Map<*, *>,
    private val eventHandler: AspenCameraHandler  // 接收 Handler，用于发送事件到 Flutter
) : PlatformView {
    companion object {
        private const val TAG = "AspenCameraView"
        private const val PLAY_MODE_LIVE = 0

        private const val DELAY_SDK_INIT: Long = 300
        private const val DELAY_P2P_INIT: Long = 800
        private const val DELAY_PLAY_INIT: Long = 1100
    }

    private val deviceId: String = params["deviceId"] as? String ?: ""
    private val channelNo: Int = params["channelNo"] as? Int ?: 0
    private val p2pId: String = params["p2pId"] as? String ?: ""
    private val p2pInitString: String = params["p2pInitString"] as? String ?: ""

    private val surfaceView: SurfaceView = SurfaceView(activity)
    private var isInitialized = false

    init {
        Log.d(TAG, "初始化视图: deviceId=$deviceId, p2pId=$p2pId")
        //路由到播放页面防止卡顿
        surfaceView.postDelayed({
            initializePlayer()
        }, DELAY_SDK_INIT)
    }

    private fun initializePlayer() {
        try {
            Log.d(TAG, "初始化 JVPlayerUtil")
            Log.d(TAG, "P2P 参数: p2pId=$p2pId")

            // 检查参数
            if (p2pId.isEmpty() || p2pInitString.isEmpty()) {
                Log.e(TAG, "P2P 参数为空，无法初始化")
                return
            }

            // 强制清理旧状态（如果有）
            try {
                Log.d(TAG, "清理可能存在的旧状态")
                JVPlayerUtil.instance.stopPlayer()
                JVPlayerUtil.instance.onDestroy()
                // 等待清理完成
                Thread.sleep(200)
            } catch (e: Exception) {
                Log.w(TAG, "清理旧状态失败（可能未初始化过）", e)
            }

            val callback = object : JVPlayerCallback {
                /**
                 * 播放器事件回调
                 *
                 * 通过 EventChannel 发送事件到 Flutter
                 */
                override fun onPlayerEvent(event_type: Int, event_state: Int) {
                    Log.d(TAG, "播放器事件: type=$event_type, state=$event_state")

                    when (event_type) {
                        // ═══════════════════════════════════════════════
                        // P2P 连接事件
                        // ═══════════════════════════════════════════════
                        PlayEventCode.PPCS -> {
                            when (event_state) {
                                PlayEventCode.ERROR_PPCS_TIME_OUT -> {
                                    Log.d(TAG, "P2P: 连接设备服务器超时")

                                    // EventChannel: 发送超时错误到 Flutter
                                    eventHandler.sendPlayerError(
                                        "P2P_TIMEOUT",
                                        "P2P 连接超时",
                                        null
                                    )
                                }

                                PlayEventCode.ERROR_PPCS_SUCCESSFUL -> {
                                    Log.d(TAG, "P2P: 连接设备服务器成功")

                                    // EventChannel: 发送 P2P 连接成功事件到 Flutter
                                    eventHandler.sendPlayerEvent(mapOf(
                                        "type" to "p2p",
                                        "event" to "connected"
                                    ))
                                }

                                PlayEventCode.ERROR_PPCS_NOT_INITIALIZED -> {
                                    Log.d(TAG, "P2P: 设备服务器连接已销毁，需要重新初始化")

                                    // EventChannel: 发送错误到 Flutter
                                    eventHandler.sendPlayerError(
                                        "P2P_NOT_INITIALIZED",
                                        "P2P 连接已销毁",
                                        null
                                    )
                                }

                                PlayEventCode.ERROR_PPCS_INVALID_ID -> {
                                    Log.d(TAG, "P2P: P2P ID 无效")

                                    // EventChannel: 发送错误到 Flutter
                                    eventHandler.sendPlayerError(
                                        "P2P_INVALID_ID",
                                        "P2P ID 无效",
                                        null
                                    )
                                }
                            }
                        }

                        // ═══════════════════════════════════════════════
                        // 播放器事件
                        // ═══════════════════════════════════════════════
                        PlayEventCode.JPET_PLAY -> {
                            when (event_state) {
                                PlayEventCode.JPS_VIDEO_LOADING -> {
                                    Log.d(TAG, "播放器: 连接中")

                                    // EventChannel: 发送连接中事件到 Flutter
                                    eventHandler.sendPlayerEvent(mapOf(
                                        "type" to "player",
                                        "event" to "connecting"
                                    ))
                                }

                                PlayEventCode.JPS_CONNECTED -> {
                                    Log.d(TAG, "播放器: 连接成功")

                                    // EventChannel: 发送连接成功事件到 Flutter
                                    eventHandler.sendPlayerEvent(mapOf(
                                        "type" to "player",
                                        "event" to "connected"
                                    ))
                                }

                                PlayEventCode.JPS_CONNECT_FAILED -> {
                                    Log.d(TAG, "播放器: 断开连接")

                                    // EventChannel: 发送连接失败错误到 Flutter
                                    eventHandler.sendPlayerError(
                                        "CONNECT_FAILED",
                                        "播放器连接失败",
                                        null
                                    )
                                }

                                PlayEventCode.JPS_VIDEO_DECODE_SUCCESS -> {
                                    Log.d(TAG, "播放器: 读取到 I 帧，开始显示画面")

                                    // EventChannel: 发送视频准备好事件到 Flutter
                                    eventHandler.sendPlayerEvent(mapOf(
                                        "type" to "player",
                                        "event" to "video_ready"
                                    ))

                                    // 打开音频
                                    Handler(Looper.getMainLooper()).postDelayed({
                                        try {
                                            JVPlayerUtil.instance.switchAudio(true)
                                            Log.d(TAG, "音频已打开")
                                        } catch (e: Exception) {
                                            Log.e(TAG, "打开音频失败", e)
                                        }
                                    }, 0)
                                }
                            }
                        }
                    }
                }

                /**
                 * 录音数据回调
                 */
                override fun onPlayerRecordSound(player_Id: Int, data: ByteArray, data_size: Int) {
                    // 录音回调（对讲功能需要）
                }
            }

            // 初始化 SDK（不包含 P2P 初始化）
            JVPlayerUtil.instance.init(
                activity,
                p2pId,
                p2pInitString,
                surfaceView,
                PLAY_MODE_LIVE,
                1,
                "",
                callback,
                false  // true: 包含 P2P 初始化
            )
            Log.d(TAG, "初始化 SDK（不包含 P2P 初始化)，")

            surfaceView.postDelayed({
                try {
                    JVPlayerUtil.instance.initP2P()
                    Log.d(TAG, "延时初始化P2p，成功")
                } catch (e: Exception) {
                    Log.e(TAG, "延时初始化P2p，失败", e)
                }
            }, DELAY_P2P_INIT)

            isInitialized = true
            Log.d(TAG, "JVPlayerUtil 初始化成功")

            // 延迟启动播放，等待初始化完成
            surfaceView.postDelayed({
                try {
                    JVPlayerUtil.instance.startPlayer()
                    Log.d(TAG, "开始播放")
                } catch (e: Exception) {
                    Log.e(TAG, "播放失败", e)
                }
            }, DELAY_PLAY_INIT)

        } catch (e: Exception) {
            Log.e(TAG, "初始化失败", e)
        }
    }

    override fun getView(): View {
        return surfaceView
    }

    override fun dispose() {
        Log.d(TAG, "销毁视图,isInitialized=$isInitialized")
        if (!isInitialized) {
            return
        }

        // 只停止播放，不销毁 SDK
        try {
            Log.d(TAG, "停止播放（不销毁 SDK）")
            JVPlayerUtil.instance.stopPlayer()
            // 不调用 onDestroy()，保留 SDK 状态
            JVPlayerUtil.instance.onDestroy()
            isInitialized = false
            Log.d(TAG, "播放已停止")
        } catch (e: Exception) {
            Log.e(TAG, "停止失败", e)
        }
    }
}
