# 摄像头直播原生层集成文档

本文档说明 Android 和 iOS 端需要实现的原生代码，用于接入各厂商摄像头 SDK。

## 概述

Flutter 层通过以下两种方式与原生通信：
1. **MethodChannel**：用于调用原生 SDK 方法（初始化、播放、暂停等）
2. **PlatformView**：用于嵌入原生视频播放视图

---

## 一、MethodChannel 接口规范

### 1.1 Channel 命名规范

每个厂商使用独立的 Channel：

| 厂商 | Channel 名称 |
|------|-------------|
| Aspen | `camera/aspen` |
| Ezviz（萤石） | `camera/ezviz` |
| Hualai（华来） | `camera/hualai` |

### 1.2 方法列表

所有厂商的 Channel 必须实现以下方法：

#### `initialize`
**说明**：初始化播放器

**参数**：
```json
{
  "deviceId": "设备 ID（必填）",
  "p2pId": "P2P 连接 ID（可选，部分厂商需要）",
  "p2pInitString": "P2P 初始化字符串（可选，部分厂商需要）",
  "channelNo": 通道号（可选，默认 0）
}
```

**返回**：`null`（成功）或抛出异常

---

#### `play`
**说明**：开始播放

**参数**：无

**返回**：`null`（成功）或抛出异常

---

#### `pause`
**说明**：暂停播放

**参数**：无

**返回**：`null`（成功）或抛出异常

---

#### `dispose`
**说明**：停止播放并释放资源

**参数**：无

**返回**：`null`（成功）或抛出异常

---

#### `takeSnapshot`
**说明**：截图

**参数**：无

**返回**：图片保存的本地路径（`String`），失败返回 `null`

---

#### `switchQuality`
**说明**：切换清晰度

**参数**：
```json
{
  "quality": "low | medium | high"
}
```

**返回**：`null`（成功）或抛出异常

---

### 1.3 预留方法（暂不实现）

以下方法预留接口，当前暂不实现：
- `startRecording`：开始录像
- `stopRecording`：停止录像
- `startTalk`：开始对讲
- `stopTalk`：停止对讲
- `ptzControl`：云台控制

---

## 二、PlatformView 集成规范

### 2.1 ViewType 命名规范

每个厂商需要注册独立的 PlatformView：

| 厂商 | ViewType 名称 |
|------|--------------|
| Aspen | `camera_view_aspen` |
| Ezviz（萤石） | `camera_view_ezviz` |
| Hualai（华来） | `camera_view_hualai` |

### 2.2 创建参数

Flutter 创建 PlatformView 时传递以下参数：

```json
{
  "deviceId": "设备 ID",
  "channelNo": 通道号（默认 0）
}
```

原生端需要根据这些参数创建并返回对应的视频播放视图。

---

## 三、Android 端实现示例

### 3.1 MethodChannel 处理（Kotlin）

```kotlin
// MainActivity.kt 或独立的 Handler 类
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class CameraChannelHandler(private val flutterEngine: FlutterEngine) {

    fun setupChannels() {
        // Aspen 厂商
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "camera/aspen"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    val deviceId = call.argument<String>("deviceId")!!
                    val p2pId = call.argument<String>("p2pId")
                    val p2pInitString = call.argument<String>("p2pInitString")
                    val channelNo = call.argument<Int>("channelNo") ?: 0

                    try {
                        // TODO: 调用 Aspen SDK 初始化
                        // AspenSDK.initialize(deviceId, p2pId, channelNo)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("INIT_ERROR", e.message, null)
                    }
                }

                "play" -> {
                    try {
                        // TODO: 调用 Aspen SDK 播放
                        // AspenSDK.play()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("PLAY_ERROR", e.message, null)
                    }
                }

                "pause" -> {
                    try {
                        // TODO: 调用 Aspen SDK 暂停
                        // AspenSDK.pause()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("PAUSE_ERROR", e.message, null)
                    }
                }

                "dispose" -> {
                    try {
                        // TODO: 调用 Aspen SDK 释放资源
                        // AspenSDK.dispose()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("DISPOSE_ERROR", e.message, null)
                    }
                }

                "takeSnapshot" -> {
                    try {
                        // TODO: 调用 Aspen SDK 截图
                        // val path = AspenSDK.takeSnapshot()
                        val path = "/path/to/snapshot.jpg"
                        result.success(path)
                    } catch (e: Exception) {
                        result.error("SNAPSHOT_ERROR", e.message, null)
                    }
                }

                "switchQuality" -> {
                    val quality = call.argument<String>("quality")!!
                    try {
                        // TODO: 调用 Aspen SDK 切换清晰度
                        // AspenSDK.switchQuality(quality)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("QUALITY_ERROR", e.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }

        // TODO: 同样方式实现 camera/ezviz 和 camera/hualai
    }
}
```

在 `MainActivity` 中注册：

```kotlin
class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 注册 MethodChannel
        CameraChannelHandler(flutterEngine).setupChannels()

        // 注册 PlatformView（见下方）
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "camera_view_aspen",
                AspenCameraViewFactory()
            )
    }
}
```

### 3.2 PlatformView 实现（Kotlin）

```kotlin
import android.content.Context
import android.view.View
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

// ViewFactory
class AspenCameraViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<String, Any> ?: emptyMap()
        return AspenCameraView(context, params)
    }
}

// PlatformView 实现
class AspenCameraView(
    private val context: Context,
    private val params: Map<String, Any>
) : PlatformView {

    private val deviceId: String = params["deviceId"] as? String ?: ""
    private val channelNo: Int = params["channelNo"] as? Int ?: 0

    // TODO: 使用 Aspen SDK 创建视频播放 View
    private val videoView: View = createAspenVideoView()

    private fun createAspenVideoView(): View {
        // TODO: 调用 Aspen SDK 创建播放视图
        // return AspenSDK.createVideoView(context, deviceId, channelNo)
        return View(context) // 临时占位
    }

    override fun getView(): View {
        return videoView
    }

    override fun dispose() {
        // TODO: 释放 Aspen SDK 资源
        // AspenSDK.releaseView(videoView)
    }
}
```

---

## 四、iOS 端实现示例

### 4.1 MethodChannel 处理（Swift）

```swift
// AppDelegate.swift
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController

        // 注册 MethodChannel
        setupAspenChannel(controller: controller)

        // 注册 PlatformView（见下方）
        let registrar = self.registrar(forPlugin: "AspenCameraPlugin")!
        let factory = AspenCameraViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "camera_view_aspen")

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func setupAspenChannel(controller: FlutterViewController) {
        let channel = FlutterMethodChannel(
            name: "camera/aspen",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "initialize":
                let args = call.arguments as! [String: Any]
                let deviceId = args["deviceId"] as! String
                let p2pId = args["p2pId"] as? String
                let channelNo = args["channelNo"] as? Int ?? 0

                // TODO: 调用 Aspen SDK 初始化
                // AspenSDK.initialize(deviceId, p2pId, channelNo)
                result(nil)

            case "play":
                // TODO: 调用 Aspen SDK 播放
                // AspenSDK.play()
                result(nil)

            case "pause":
                // TODO: 调用 Aspen SDK 暂停
                // AspenSDK.pause()
                result(nil)

            case "dispose":
                // TODO: 调用 Aspen SDK 释放资源
                // AspenSDK.dispose()
                result(nil)

            case "takeSnapshot":
                // TODO: 调用 Aspen SDK 截图
                // let path = AspenSDK.takeSnapshot()
                let path = "/path/to/snapshot.jpg"
                result(path)

            case "switchQuality":
                let args = call.arguments as! [String: Any]
                let quality = args["quality"] as! String

                // TODO: 调用 Aspen SDK 切换清晰度
                // AspenSDK.switchQuality(quality)
                result(nil)

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}
```

### 4.2 PlatformView 实现（Swift）

```swift
import Flutter
import UIKit

// ViewFactory
class AspenCameraViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return AspenCameraView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

// PlatformView 实现
class AspenCameraView: NSObject, FlutterPlatformView {
    private var _view: UIView

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        let params = args as? [String: Any] ?? [:]
        let deviceId = params["deviceId"] as? String ?? ""
        let channelNo = params["channelNo"] as? Int ?? 0

        // TODO: 使用 Aspen SDK 创建视频播放 View
        // _view = AspenSDK.createVideoView(deviceId: deviceId, channelNo: channelNo)
        _view = UIView(frame: frame) // 临时占位
        _view.backgroundColor = .black

        super.init()
    }

    func view() -> UIView {
        return _view
    }

    deinit {
        // TODO: 释放 Aspen SDK 资源
        // AspenSDK.releaseView(_view)
    }
}
```

---

## 五、SDK 导入方式

### 5.1 Android（build.gradle）

在 `android/app/build.gradle` 中添加：

```gradle
dependencies {
    // Aspen SDK（示例，根据实际情况调整）
    implementation files('libs/aspen_sdk.aar')
    // 或者 Maven 仓库
    implementation 'com.aspen:camera-sdk:1.0.0'

    // Ezviz SDK
    implementation files('libs/ezviz_sdk.aar')

    // Hualai SDK
    implementation files('libs/hualai_sdk.aar')
}
```

### 5.2 iOS（Podfile）

在 `ios/Podfile` 中添加：

```ruby
target 'Runner' do
  # Aspen SDK
  pod 'AspenCameraSDK', '~> 1.0'
  # 或者本地路径
  pod 'AspenCameraSDK', :path => './Frameworks/AspenSDK'

  # Ezviz SDK
  pod 'EzvizSDK', '~> 5.0'

  # Hualai SDK
  pod 'HualaiSDK', '~> 2.0'
end
```

---

## 六、调试技巧

### 6.1 Flutter 端日志

Flutter 端已集成 `AppLogger`，查看日志：

```bash
# 查看所有摄像头相关日志
flutter logs | grep "nblog.*\[ApiLog\]"
```

### 6.2 Android 端日志

```kotlin
Log.d("CameraAspen", "初始化成功: deviceId=$deviceId")
```

### 6.3 iOS 端日志

```swift
print("CameraAspen: 初始化成功 - deviceId=\(deviceId)")
```

---

## 七、常见问题

### 7.1 如何判断是哪个厂商？

Flutter 层通过 `device.oem` 字段判断，原生端根据 Channel 名称区分：
- `camera/aspen` → Aspen SDK
- `camera/ezviz` → Ezviz SDK
- `camera/hualai` → Hualai SDK

### 7.2 视频流地址从哪里来？

部分厂商需要 P2P 连接参数（`p2pId`、`p2pInitString`），这些参数由后端接口返回，存储在 `DeviceModel` 中。

### 7.3 如何测试原生代码？

1. 在原生端打印日志，确认 MethodChannel 被调用
2. 先用简单的 `View(context)` 测试 PlatformView 是否正常嵌入
3. 再接入真实 SDK

---

## 八、下一步工作

1. **Aspen 厂商**：优先实现 Aspen 的完整流程
2. **Ezviz / Hualai**：参考 Aspen 的实现模式，复制一套代码
3. **测试**：使用真实设备测试播放、截图、清晰度切换等功能

---

## 附录：文件清单

### Flutter 端
- `lib/core/camera/camera_player.dart` - 抽象接口
- `lib/core/camera/camera_player_factory.dart` - 工厂类
- `lib/core/camera/impl/aspen_camera_player.dart` - Aspen 实现
- `lib/core/camera/impl/ezviz_camera_player.dart` - Ezviz 空实现
- `lib/core/camera/impl/hualai_camera_player.dart` - Hualai 空实现
- `lib/pages/camera/camera_live_page.dart` - 直播页面
- `lib/pages/camera/providers/camera_live_provider.dart` - 直播 Provider

### Android 端（待实现）
- `android/app/src/main/kotlin/.../CameraChannelHandler.kt`
- `android/app/src/main/kotlin/.../AspenCameraView.kt`
- `android/app/src/main/kotlin/.../AspenCameraViewFactory.kt`

### iOS 端（待实现）
- `ios/Runner/AppDelegate.swift` - 注册 Channel 和 PlatformView
- `ios/Runner/Camera/AspenCameraView.swift`
- `ios/Runner/Camera/AspenCameraViewFactory.swift`
