import SwiftUI

/// Entry point of the Game feature.
/// Builds the view through `GameDependencies` and resolves the routes to the features opened from it.
@MainActor
final class GameCoordinator: Coordinator {
    /// One case per feature that can be opened from Game.
    enum Route: Hashable {
        // @codegen:routes
    }

    private let dependencies: GameDependencies

    init(dependencies: GameDependencies = GameDependencies()) {
        self.dependencies = dependencies
    }

    func start() -> some View {
        GameView(dependencies: dependencies)
            .navigationDestination(for: Route.self) { route in
                self.destination(for: route)
            }
    }

    /// Root view of the external display (a TV over AirPlay): the game open on the iPhone or iPad, in its TV
    /// layout. Started by the external display scene in `App/ExternalDisplaySceneDelegate.swift`.
    func startExternalDisplay() -> some View {
        GameExternalDisplayView(display: dependencies.resolveExternalDisplay())
    }

    func destination(for route: Route) -> AnyView {
        switch route {
        // @codegen:destinations
        }
    }
}
