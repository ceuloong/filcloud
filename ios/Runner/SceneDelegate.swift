import Flutter
import UIKit

/// UIScene 生命周期入口；在 window / FlutterViewController 就绪后注册原生 Method Channel。
class SceneDelegate: FlutterSceneDelegate {
    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)

        guard let controller = window?.rootViewController as? FlutterViewController else {
            return
        }

        PasskeyChannel.register(with: controller)

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.bindFlutterChannels(with: controller)
        }
    }
}
