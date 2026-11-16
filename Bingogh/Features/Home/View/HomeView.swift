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
            // Wire these to NavigationLink(value: HomeCoordinator.Route.<child>) once the game features exist.
            DSButton(systemImage: "plus") {}
                .localized("home.newGame")
            DSButton(systemImage: "play.fill", style: .translucent) {}
                .localized("home.continueGame")
        }
    }
}

#Preview {
    NavigationStack {
        HomeCoordinator().start()
    }
}
