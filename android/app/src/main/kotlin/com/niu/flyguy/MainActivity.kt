package com.niu.flyguy

import com.niu.flyguy.camera.AspenCameraHandler
import com.niu.flyguy.camera.AspenCameraViewFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var cameraHandler: AspenCameraHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ═══════════════════════════════════════════════════════════════
        // 注册 Aspen 摄像头通信处理器（MethodChannel + EventChannel）
        // ═══════════════════════════════════════════════════════════════
        cameraHandler = AspenCameraHandler(flutterEngine, this)
        cameraHandler?.register()

        // ═══════════════════════════════════════════════════════════════
        // 注册 Aspen 摄像头 PlatformView
        // 传递 cameraHandler，让 PlatformView 可以发送事件到 Flutter
        // ═══════════════════════════════════════════════════════════════
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "camera_view_aspen",
                AspenCameraViewFactory(this, cameraHandler!!)  // 传递 Handler
            )
    }

    override fun onDestroy() {
        cameraHandler?.unregister()
        super.onDestroy()
    }
}
