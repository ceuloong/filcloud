import UIKit
import Flutter
import UserNotifications
import AuthenticationServices

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterPluginRegistrant {

    /// 设备令牌
    var deviceToken: String?

    private var deviceTokenChannel: FlutterMethodChannel?
    private weak var flutterController: FlutterViewController?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // UIScene 下 FlutterViewController 从 Storyboard 创建时，通过 pluginRegistrant 注册插件。
        pluginRegistrant = self

        /// 请求通知权限
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Notifications permission granted")

                /// 在主线程中注册 APNs 推送通知
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Notifications permission denied: \(String(describing: error?.localizedDescription))")
            }
        }

        /// 返回应用程序启动结果
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    /// FlutterPluginRegistrant：供 UIScene / Storyboard 创建的引擎注册插件。
    func register(with registry: FlutterPluginRegistry) {
        GeneratedPluginRegistrant.register(with: registry)
    }

    /// 由 SceneDelegate 在 FlutterViewController 就绪后调用。
    func bindFlutterChannels(with controller: FlutterViewController) {
        flutterController = controller
        deviceTokenChannel = FlutterMethodChannel(
            name: "com.fil.links/user_token",
            binaryMessenger: controller.binaryMessenger
        )
        if let token = deviceToken {
            deviceTokenChannel?.invokeMethod("updateDeviceToken", arguments: token)
        }
    }

    /// 成功注册推送通知及令牌更新时，并将设备令牌发送给 Flutter
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        /// 打印设备令牌
        print("Device Token: \(token)")
        /// 保存设备令牌
        self.deviceToken = token

        if deviceTokenChannel == nil, let controller = resolveFlutterController() {
            bindFlutterChannels(with: controller)
        }
        deviceTokenChannel?.invokeMethod("updateDeviceToken", arguments: token)
    }

    /// 注册推送通知失败时，打印错误信息
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    private func resolveFlutterController() -> FlutterViewController? {
        if let flutterController {
            return flutterController
        }
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if let controller = window.rootViewController as? FlutterViewController {
                    return controller
                }
            }
        }
        return window?.rootViewController as? FlutterViewController
    }
}
