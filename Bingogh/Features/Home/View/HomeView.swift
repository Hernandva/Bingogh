import BingoghUI
import SwiftUI

/// Inicio: the wordmark over the night sky and the two ways into a game.
struct HomeView: View {
    @State private var viewModel: HomeViewModel

    /// Receives only the container and resolves the view model from it.
    init(dependencies: HomeDependencies) {
        _viewModel = State(initialValue: dependencies.resolveViewModel())
    }

    var body: some View {
        DSNightScreen {
            Spacer()
            DSWordmark().localized("home.title")
            Spacer()
                .frame(minHeight: DSSpacing.large, maxHeight: DSSpacing.espacioXxxl * 2)
            actions
        }
        .task { await viewModel.load() }
    }

    private var actions: some View {
        DSButtonGroup {
            DSNavigationButton(value: HomeCoordinator.Route.game(.empty), systemImage: "plus")
                .localized("home.newGame")
                .simultaneousGesture(TapGesture().onEnded {
                    Task { await viewModel.startNewGame() }
                })
            if let savedGame = viewModel.viewData.savedGame {
                DSNavigationButton(
                    value: HomeCoordinator.Route.game(savedGame),
                    systemImage: "play.fill",
                    style: .translucent
                )
                    .localized("home.continueGame")
                    .transition(.opacity)
            }
        }
        .animation(.default, value: viewModel.viewData.canContinueGame)
    }
}

#Preview {
    NavigationStack {
        HomeCoordinator().start()
    }
}
