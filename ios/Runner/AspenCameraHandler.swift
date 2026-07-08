import Flutter
import UIKit

/// Aspen 摄像头通信处理器
///
/// 职责：
/// 1. MethodChannel: 处理 Flutter 的控制调用（play, pause, dispose 等）
/// 2. EventChannel: 推送播放器状态事件到 Flutter
class AspenCameraHandler: NSObject {

    // ═══════════════════════════════════════════════════════════════
    // MethodChannel - Flutter 调用 iOS
    // ═══════════════════════════════════════════════════════════════
    private let methodChannel: FlutterMethodChannel

    // ═══════════════════════════════════════════════════════════════
    // EventChannel - iOS 推送事件到 Flutter
    // ═══════════════════════════════════════════════════════════════
    private let eventChannel: FlutterEventChannel
    private var eventSink: FlutterEventSink?

    // SDK 相关
    private var isPlayerInitialized = false

    // 通道名称常量
    private static let METHOD_CHANNEL_NAME = "camera/aspen"
    private static let EVENT_CHANNEL_NAME = "camera/aspen/events"

    init(messenger: FlutterBinaryMessenger) {
        self.methodChannel = FlutterMethodChannel(
            name: AspenCameraHandler.METHOD_CHANNEL_NAME,
            binaryMessenger: messenger
        )

        self.eventChannel = FlutterEventChannel(
            name: AspenCameraHandler.EVENT_CHANNEL_NAME,
            binaryMessenger: messenger
        )

        super.init()

        print("AspenCameraHandler: 初始化完成")
    }

    // ─────────────────────────────────────────────────────────
    // 注册通道
    // ─────────────────────────────────────────────────────────
    func register() {
        print("AspenCameraHandler: 注册通信通道")

        // 注册 MethodChannel
        methodChannel.setMethodCallHandler { [weak self] (call, result) in
            self?.handleMethodCall(call: call, result: result)
        }

        // 注册 EventChannel
        eventChannel.setStreamHandler(self)
    }

    // ─────────────────────────────────────────────────────────
    // 处理 Flutter 的方法调用
    // ─────────────────────────────────────────────────────────
    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        do {
            switch call.method {
            case "initialize":
                handleInitialize(call: call, result: result)
            case "play":
                handlePlay(result: result)
            case "pause":
                handlePause(result: result)
            case "dispose":
                handleDispose(result: result)
            case "takeSnapshot":
                handleSnapshot(result: result)
            case "switchQuality":
                handleSwitchQuality(call: call, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        } catch {
            print("AspenCameraHandler: MethodChannel 方法调用异常: \(call.method), \(error)")
            result(FlutterError(
                code: "EXCEPTION",
                message: error.localizedDescription,
                details: nil
            ))
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MethodChannel 方法实现
    // ═══════════════════════════════════════════════════════════════

    private func handleInitialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let deviceId = args["deviceId"] as? String,
              let p2pId = args["p2pId"] as? String,
              let p2pInitString = args["p2pInitString"] as? String else {
            result(FlutterError(
                code: "INVALID_ARGS",
                message: "初始化参数缺失",
                details: nil
            ))
            return
        }

        let channelNo = args["channelNo"] as? Int ?? 0

        print("AspenCameraHandler: MethodChannel 初始化")
        print("  deviceId=\(deviceId)")
        print("  p2pId=\(p2pId)")
        print("  channelNo=\(channelNo)")

        // iOS SDK 不需要在这里初始化，会在 PlatformView 中初始化
        // 这里只是记录状态
        isPlayerInitialized = true
        result(nil)
    }

    private func handlePlay(result: @escaping FlutterResult) {
        print("AspenCameraHandler: MethodChannel 开始播放")

        // iOS 端播放逻辑由 PlatformView 控制
        // 这里预留接口，可以通过通知或代理模式通知 PlatformView

        result(nil)
    }

    private func handlePause(result: @escaping FlutterResult) {
        print("AspenCameraHandler: MethodChannel 暂停播放")

        // iOS 端暂停逻辑由 PlatformView 控制

        result(nil)
    }

    private func handleDispose(result: @escaping FlutterResult) {
        print("AspenCameraHandler: MethodChannel 收到 dispose 请求")

        // ✅ 停止并清理当前激活的播放器（等同于 Android 的 stopPlayer + onDestroy）
        AspenCameraViewFactory.viewLock.lock()

        print("AspenCameraHandler: 检查 activeView 状态...")
        if let activeView = AspenCameraViewFactory.activeView {
            print("AspenCameraHandler: ✅ 找到激活的播放器 viewId=\(activeView.viewId)")
            activeView.forceCleanup()
            print("AspenCameraHandler: ✅ 播放器已停止并清理")
        } else {
            print("AspenCameraHandler: ❌ activeView 是 nil，无法清理")
        }

        AspenCameraViewFactory.viewLock.unlock()

        isPlayerInitialized = false
        result(nil)

        print("AspenCameraHandler: ✅ dispose 完成")
    }

    private func handleSnapshot(result: @escaping FlutterResult) {
        print("AspenCameraHandler: MethodChannel 截图")

        // 通知 PlatformView 执行截图
        // 这里需要通过通知机制传递给当前的 AspenCameraView
        NotificationCenter.default.post(
            name: NSNotification.Name("AspenCameraSnapshotRequest"),
            object: nil,
            userInfo: ["result": result]
        )
    }

    private func handleSwitchQuality(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let quality = args["quality"] as? String else {
            result(FlutterError(
                code: "INVALID_ARGS",
                message: "参数缺失",
                details: nil
            ))
            return
        }

        print("AspenCameraHandler: MethodChannel 切换清晰度: \(quality)")

        // 通知 PlatformView 切换清晰度
        NotificationCenter.default.post(
            name: NSNotification.Name("AspenCameraSwitchQuality"),
            object: nil,
            userInfo: ["quality": quality, "result": result]
        )
    }

    // ═══════════════════════════════════════════════════════════════
    // EventChannel - 推送事件到 Flutter
    // ═══════════════════════════════════════════════════════════════

    /// 发送事件到 Flutter
    ///
    /// - Parameters:
    ///   - type: 事件类型（"p2p" 或 "player"）
    ///   - event: 事件名称（"connected", "video_ready" 等）
    ///   - data: 附加数据（可选）
    func sendEvent(type: String, event: String, data: [String: Any]? = nil) {
        guard let sink = eventSink else {
            print("AspenCameraHandler: EventSink 未初始化，无法发送事件")
            return
        }

        // 必须在主线程推送
        DispatchQueue.main.async {
            var eventData: [String: Any] = [
                "type": type,
                "event": event
            ]
            if let data = data {
                eventData["data"] = data
            }

            print("AspenCameraHandler: EventChannel 推送事件: \(eventData)")
            sink(eventData)
        }
    }

    /// 发送错误到 Flutter
    func sendError(code: String, message: String, details: Any? = nil) {
        guard let sink = eventSink else { return }

        DispatchQueue.main.async {
            sink(FlutterError(code: code, message: message, details: details))
        }
    }

    // ─────────────────────────────────────────────────────────
    // 注销通道
    // ─────────────────────────────────────────────────────────
    func unregister() {
        print("AspenCameraHandler: 注销通信通道")
        methodChannel.setMethodCallHandler(nil)
        eventChannel.setStreamHandler(nil)
    }
}

// ═══════════════════════════════════════════════════════════════
// EventChannel StreamHandler 实现
// ═══════════════════════════════════════════════════════════════
extension AspenCameraHandler: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("AspenCameraHandler: Flutter 开始监听事件")
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("AspenCameraHandler: Flutter 取消监听事件")
        self.eventSink = nil
        return nil
    }
}
