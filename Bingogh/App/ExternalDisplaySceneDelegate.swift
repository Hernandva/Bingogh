import SwiftUI
import UIKit

/// Scene of the external display (a TV over AirPlay) on iOS 18 to 26, declared in Info.plist: a window that
/// shows the Game feature's TV view. On iOS 27 and later the scene comes from `externalDisplayAccessory()`.
/// The TV cannot be touched; the game is played from the iPhone or iPad.
final class ExternalDisplaySceneDelegate: NSObject, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let size = windowScene.screen.bounds.size
        ExternalDisplayLog.logger.info("External display connected: \(size.width) x \(size.height)")
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: GameCoordinator().startExternalDisplay())
        window.isHidden = false
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        ExternalDisplayLog.logger.info("External display disconnected")
        window = nil
    }
}
