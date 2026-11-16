import OSLog
import SwiftUI

/// Log of the external display (a TV over AirPlay), category `ExternalDisplay` in the console.
enum ExternalDisplayLog {
    static let logger = Logger(subsystem: "dev.hdvillamil.bingogh", category: "ExternalDisplay")
}

extension View {
    /// Shows the game's TV layout on an external display (a TV over AirPlay) instead of mirroring the screen.
    ///
    /// - iOS 27 and later: the system only gives the app a scene for the external display after the app
    ///   registers a scene accessory, so this registers one with the Game feature's TV view.
    /// - iOS 18 to 26: the scene comes from Info.plist (`UIWindowSceneSessionRoleExternalDisplayNonInteractive`)
    ///   and `ExternalDisplaySceneDelegate`, so this does nothing.
    func externalDisplayAccessory() -> some View {
        modifier(ExternalDisplayAccessoryModifier())
    }
}

private struct ExternalDisplayAccessoryModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 27.0, *) {
            content.sceneAccessory {
                ExternalNonInteractiveAccessory {
                    GameCoordinator().startExternalDisplay()
                }
                .onAvailabilityChange { isAvailable in
                    ExternalDisplayLog.logger.info("External display accessory available: \(isAvailable)")
                }
            }
        } else {
            content
        }
    }
}
