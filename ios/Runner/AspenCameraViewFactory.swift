import Flutter
import UIKit

/// Aspen 摄像头 PlatformView 工厂
///
/// 职责：
/// 1. 初始化 Aspen SDK（全局一次）
/// 2. 创建 AspenCameraView 实例
class AspenCameraViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    private let eventHandler: AspenCameraHandler

    // ═══════════════════════════════════════════════════════════════
    // 单实例保护 - 避免多个实例同时存在导致 SDK 冲突
    // ═══════════════════════════════════════════════════════════════
    static var activeView: AspenCameraView?
    static let viewLock = NSLock()

    // ═══════════════════════════════════════════════════════════════
    // SDK 全局初始化标志（保证只初始化一次）
    // ═══════════════════════════════════════════════════════════════
    private static var isSDKRegistered = false
    private static let sdkLock = NSLock()

    init(messenger: FlutterBinaryMessenger, eventHandler: AspenCameraHandler) {
        self.messenger = messenger
        self.eventHandler = eventHandler
        super.init()

        print("AspenCameraViewFactory: 初始化工厂")

        // ✅ 全局初始化 Aspen SDK（只执行一次）
        // 说明：
        // - registerSDK 内部调用 initPlayerSDK，初始化 H265/H264 解码引擎
        // - 全程只调用一次，不调用 releaseSDK
        // - 每个播放页面只做 connect/disconnect
        AspenCameraViewFactory.sdkLock.lock()
        if !AspenCameraViewFactory.isSDKRegistered {
            print("AspenCameraViewFactory: 正在初始化 Aspen 播放器 SDK...")
            JVSP2PPlayer.registerSDK()
            AspenCameraViewFactory.isSDKRegistered = true
            print("AspenCameraViewFactory: ✅ Aspen 播放器 SDK 初始化完成（解码引擎就绪）")
        } else {
            print("AspenCameraViewFactory: ⚠️ SDK 已初始化，跳过")
        }
        AspenCameraViewFactory.sdkLock.unlock()

        print("AspenCameraViewFactory: ✅ 工厂初始化完成")
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        print("AspenCameraViewFactory: 创建 PlatformView, viewId=\(viewId)")

        // ✅ 直接创建新实例（旧实例已通过 handleDispose 清理）
        let newView = AspenCameraView(
            frame: frame,
            viewId: viewId,
            arguments: args,
            eventHandler: eventHandler
        )

        // ✅ 更新当前激活的实例引用
        AspenCameraViewFactory.viewLock.lock()
        let oldView = AspenCameraViewFactory.activeView
        AspenCameraViewFactory.activeView = newView
        AspenCameraViewFactory.viewLock.unlock()

        if let old = oldView {
            print("AspenCameraViewFactory: ⚠️ 替换了旧实例 viewId=\(old.viewId)")
        } else {
            print("AspenCameraViewFactory: ✅ 这是第一个实例")
        }

        return newView
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

// ═══════════════════════════════════════════════════════════════
// AspenCameraView - 原生视图（核心实现）
// ═══════════════════════════════════════════════════════════════
class AspenCameraView: NSObject, FlutterPlatformView {
    private let _view: UIView
    private let eventHandler: AspenCameraHandler
    let viewId: Int64  // ✅ 改为 internal，让 AspenCameraHandler 可以访问

    // P2P 参数（从 Flutter 传递过来）
    private let deviceId: String
    private let p2pId: String
    private let p2pInitString: String
    private let channelNo: Int

    // SDK 播放器
    private var player: JVSP2PPlayer?
    private var isInitialized = false

    // ═══════════════════════════════════════════════════════════════
    // 线程安全标记 - 防止 dispose 后的回调崩溃
    // ═══════════════════════════════════════════════════════════════
    private var isDisposed = false
    private let lock = NSLock()  // 用于保护 isDisposed 的访问

    // 延迟常量（避免路由动画卡顿）
    private static let DELAY_INIT: TimeInterval = 0.2        // 延迟  初始化
    private static let DELAY_P2P_INIT: TimeInterval = 0.7   // 延迟  初始化 P2P
    private static let DELAY_VIDEO_READY: TimeInterval = 0.4 // 延迟  发送 video_ready 事件

    init(
        frame: CGRect,
        viewId: Int64,
        arguments args: Any?,
        eventHandler: AspenCameraHandler
    ) {
        self._view = UIView(frame: frame)
        self._view.backgroundColor = .black
        self.eventHandler = eventHandler
        self.viewId = viewId

        // 解析参数
        let params = args as? [String: Any] ?? [:]
        self.deviceId = params["deviceId"] as? String ?? ""
        self.p2pId = params["p2pId"] as? String ?? ""
        self.p2pInitString = params["p2pInitString"] as? String ?? ""
        self.channelNo = params["channelNo"] as? Int ?? 0

        super.init()

        print("AspenCameraView[\(viewId)]: 初始化")
        print("  deviceId=\(deviceId)")
        print("  p2pId=\(p2pId)")
        print("  channelNo=\(channelNo)")

        // 检查参数
        guard !p2pId.isEmpty && !p2pInitString.isEmpty else {
            print("AspenCameraView[\(viewId)]: ❌ P2P 参数为空，无法初始化")
            sendError(code: "INVALID_PARAMS", message: "P2P 参数为空")
            return
        }

        // 注册通知监听（用于接收 MethodChannel 的控制指令）
        registerNotifications()

        // 延迟初始化，避免路由动画卡顿
        DispatchQueue.main.asyncAfter(deadline: .now() + AspenCameraView.DELAY_INIT) { [weak self] in
            self?.initializePlayer()
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // FlutterPlatformView 协议方法
    // ═══════════════════════════════════════════════════════════════
    func view() -> UIView {
        return _view
    }

    /// Flutter 调用此方法时，表示 PlatformView 即将被销毁
    /// 这是清理资源的最佳时机（用户返回时立即调用）
    func dispose() {
        print("AspenCameraView[\(viewId)]: ✅ Flutter 调用 dispose()")

        // 立即停止播放和清理资源
        forceCleanup()
    }

    // ═══════════════════════════════════════════════════════════════
    // 初始化播放器
    // ═══════════════════════════════════════════════════════════════
    private func initializePlayer() {
        print("AspenCameraView[\(viewId)]: 开始初始化播放器")

        // 1. 创建播放器实例（SDK 会自动管理初始化，不需要手动调用 registerSDK）
        player = JVSP2PPlayer(view: _view, type: .online)

        // 2. 设置 KVO 监听播放器状态
        player?.addObserver(
            self,
            forKeyPath: "videoStatus",
            options: [.new, .old],
            context: nil
        )

        // ✅ 不需要添加 SDKManager 的代理，Player 会自己处理
        // JVSP2PSDKManager.addDelegate(forTarget: self)

        print("AspenCameraView[\(viewId)]: ✅ 播放器创建成功")

        // 3. 延迟初始化 P2P
        DispatchQueue.main.asyncAfter(deadline: .now() + AspenCameraView.DELAY_P2P_INIT) { [weak self] in
            self?.connectP2P()
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // 连接 P2P
    // ═══════════════════════════════════════════════════════════════
    private func connectP2P() {
        print("AspenCameraView[\(viewId)]: 开始连接 P2P")
        print("  P2P ID: \(p2pId)")
        print("  InitString: \(p2pInitString)")

        // 创建 DIDModel
        let didModel = DIDModel(did: p2pId, initString: p2pInitString)

        // 连接视频（SDK 会自动播放）
        player?.connectVideo(with: didModel)

        isInitialized = true
        print("AspenCameraView[\(viewId)]: ✅ P2P 连接请求已发送")
    }

    // ═══════════════════════════════════════════════════════════════
    // 通知监听（接收 MethodChannel 的控制指令）
    // ═══════════════════════════════════════════════════════════════
    private func registerNotifications() {
        // 截图通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSnapshotRequest(_:)),
            name: NSNotification.Name("AspenCameraSnapshotRequest"),
            object: nil
        )

        // 切换清晰度通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSwitchQuality(_:)),
            name: NSNotification.Name("AspenCameraSwitchQuality"),
            object: nil
        )
    }

    @objc private func handleSnapshotRequest(_ notification: Notification) {
        guard let result = notification.userInfo?["result"] as? FlutterResult else { return }

        print("AspenCameraView[\(viewId)]: 执行截图")

        guard let player = player else {
            result(FlutterError(code: "PLAYER_NULL", message: "播放器未初始化", details: nil))
            return
        }

        // 生成截图路径
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let fileName = "snapshot_\(timestamp).jpg"

        // 获取文档目录
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = "\(documentsPath)/\(fileName)"

        // 调用 SDK 截图方法
        let image = player.snapshotImage(atPath: filePath)
        if image.size.width > 0 {
            print("AspenCameraView[\(viewId)]: ✅ 截图成功: \(filePath)")
            result(filePath)
        } else {
            print("AspenCameraView[\(viewId)]: ❌ 截图失败")
            result(FlutterError(code: "SNAPSHOT_FAILED", message: "截图失败", details: nil))
        }
    }

    @objc private func handleSwitchQuality(_ notification: Notification) {
        guard let quality = notification.userInfo?["quality"] as? String,
              let result = notification.userInfo?["result"] as? FlutterResult else { return }

        print("AspenCameraView[\(viewId)]: 切换清晰度: \(quality)")

        // TODO: 根据 SDK 文档实现清晰度切换
        // 目前 JVS SDK 可能不支持清晰度切换，或者需要特定方法
        // 这里预留接口

        result(FlutterError(code: "NOT_IMPLEMENTED", message: "清晰度切换功能暂未实现", details: nil))
    }

    // ═══════════════════════════════════════════════════════════════
    // KVO 监听播放器状态
    // ═══════════════════════════════════════════════════════════════
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        // ✅ 检查是否已销毁
        lock.lock()
        let disposed = isDisposed
        lock.unlock()

        guard !disposed else {
            print("AspenCameraView[\(viewId)]: ⚠️ 已销毁，忽略 KVO 回调")
            return
        }

        if keyPath == "videoStatus" {
            guard let newValue = change?[.newKey] as? Int,
                  let status = JVSVideoStatus(rawValue: newValue) else {
                return
            }

            // ✅ 确保在主线程处理状态变化
            DispatchQueue.main.async { [weak self] in
                self?.handleVideoStatusChange(status)
            }
        }
    }

    private func handleVideoStatusChange(_ status: JVSVideoStatus) {
        // ✅ 再次检查是否已销毁
        lock.lock()
        let disposed = isDisposed
        lock.unlock()

        guard !disposed else {
            print("AspenCameraView[\(viewId)]: ⚠️ 已销毁，忽略状态变化")
            return
        }

        print("AspenCameraView[\(viewId)]: 视频状态变化: \(status.rawValue)")

        switch status {
        case .connecting:
            print("AspenCameraView[\(viewId)]: 🔄 播放器连接中...")
            eventHandler.sendEvent(type: "player", event: "connecting")

        case .connected:
            print("AspenCameraView[\(viewId)]: ✅ 播放器已连接")
            eventHandler.sendEvent(type: "player", event: "connected")

        case .videoPlaying:
            print("AspenCameraView[\(viewId)]: 🎬 视频播放中")
            // 视频开始播放后，延迟 500ms 发送 video_ready 事件（确保首帧渲染完成后再淡出封面）
            DispatchQueue.main.asyncAfter(deadline: .now() + AspenCameraView.DELAY_VIDEO_READY) { [weak self] in
                guard let self = self else { return }

                // 检查是否已销毁
                self.lock.lock()
                let disposed = self.isDisposed
                self.lock.unlock()

                guard !disposed else {
                    print("AspenCameraView[\(self.viewId)]: ⚠️ 已销毁，取消发送 video_ready")
                    return
                }

                self.eventHandler.sendEvent(type: "player", event: "video_ready")
            }

        case .connectFailed:
            print("AspenCameraView[\(viewId)]: ❌ 连接失败")
            sendError(code: "CONNECT_FAILED", message: "连接设备失败")

        case .disconnected:
            print("AspenCameraView[\(viewId)]: ⚠️ 连接断开")
            sendError(code: "DISCONNECTED", message: "连接已断开")

        default:
            print("AspenCameraView[\(viewId)]: ⚠️ 未知状态: \(status.rawValue)")
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // 资源清理
    // ═══════════════════════════════════════════════════════════════

    /// 强制清理资源（在 dispose 或 deinit 时调用）
    func forceCleanup() {
        print("AspenCameraView[\(viewId)]: 开始强制清理资源")

        // ✅ 防止重复清理（线程安全）
        lock.lock()
        if isDisposed {
            lock.unlock()
            print("AspenCameraView[\(viewId)]: ⚠️ 已清理过，跳过")
            return
        }
        isDisposed = true
        lock.unlock()

        // 1. 移除通知监听
        NotificationCenter.default.removeObserver(self)
        print("AspenCameraView[\(viewId)]: ✅ 通知监听已移除")

        // 2. ✅ 不需要移除 SDKManager 代理（我们没有添加）
        // Player 会自己管理它的代理

        // 3. 清理播放器
        if let playerToClean = player {
            if Thread.isMainThread {
                cleanupPlayer(playerToClean)
            } else {
                DispatchQueue.main.sync {
                    cleanupPlayer(playerToClean)
                }
            }
        }

        player = nil
        print("AspenCameraView[\(viewId)]: ✅✅✅ 资源清理完成")
    }

    deinit {
        print("AspenCameraView[\(viewId)]: deinit 开始")

        // deinit 时再次确保清理（双重保险）
        // forceCleanup() 内部有 isDisposed 检查，不会重复清理
        forceCleanup()

        // 从工厂中移除引用
        AspenCameraViewFactory.viewLock.lock()
        if AspenCameraViewFactory.activeView === self {
            AspenCameraViewFactory.activeView = nil
            print("AspenCameraView[\(viewId)]: ✅ 从工厂中移除")
        }
        AspenCameraViewFactory.viewLock.unlock()

        print("AspenCameraView[\(viewId)]: deinit 完成")
    }

    /// 清理播放器资源（必须在主线程调用）
    private func cleanupPlayer(_ playerToClean: JVSP2PPlayer) {
        print("AspenCameraView[\(viewId)]: 清理播放器...")

        // 1. 移除 KVO（必须在添加 KVO 的线程移除）
        playerToClean.removeObserver(self, forKeyPath: "videoStatus")
        print("AspenCameraView[\(viewId)]: ✅ KVO 已移除")

        // 2. 停止播放和断开连接（厂商说：disconnect() 就够了，不需要调用 releaseSDK）
        if isInitialized {
            playerToClean.stopPlayVideo()
            playerToClean.disconnect()  // disconnect 内部会自动清理资源
            print("AspenCameraView[\(viewId)]: ✅ 播放已停止，连接已断开")
        }

        // 3. 释放播放器引用
        player = nil

        print("AspenCameraView[\(viewId)]: ✅ 清理完成")
    }

    // ═══════════════════════════════════════════════════════════════
    // 辅助方法
    // ═══════════════════════════════════════════════════════════════
    private func sendError(code: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.eventHandler.sendError(code: code, message: message, details: nil)
        }
    }
}
