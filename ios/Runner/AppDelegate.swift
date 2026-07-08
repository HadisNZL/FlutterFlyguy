import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var cameraHandler: AspenCameraHandler?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // ✅ 不要在这里初始化，等待 Flutter 引擎准备好
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // ═══════════════════════════════════════════════════════════════
    // Flutter 引擎已准备好，现在初始化摄像头模块
    // ═══════════════════════════════════════════════════════════════

    print("AppDelegate: 开始初始化 Aspen 摄像头模块")

    // 1. 通过 registrar 获取 messenger（正确的方式）
    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AspenCameraPlugin")!
    let messenger = registrar.messenger()

    // 2. 创建并注册 MethodChannel + EventChannel 处理器
    cameraHandler = AspenCameraHandler(messenger: messenger)
    cameraHandler?.register()

    // 3. 确保 cameraHandler 已创建
    guard let handler = cameraHandler else {
      print("AppDelegate: ❌ cameraHandler 初始化失败")
      return
    }

    // 4. 创建 PlatformView 工厂
    let factory = AspenCameraViewFactory(
      messenger: messenger,
      eventHandler: handler
    )

    // 5. 注册 PlatformView
    registrar.register(
      factory,
      withId: "camera_view_aspen"
    )

    print("AppDelegate: ✅ Aspen 摄像头模块注册完成")

    // 6. 最后注册其他 Flutter 插件
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
