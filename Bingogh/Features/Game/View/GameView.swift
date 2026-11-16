import BingoghUI
import SwiftUI

/// Juego: the drum and the caller board. iPhone shows one at a time, chosen with "Bombo / Tablero";
/// iPad shows both side by side. The TV layout, `GameTVLayout`, is for the external display over AirPlay.
struct GameView: View {
    @State private var viewModel: GameViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass

    /// Receives only the container and resolves the view model from it.
    init(dependencies: GameDependencies) {
        _viewModel = State(initialValue: dependencies.resolveViewModel())
    }

    var body: some View {
        DSGameScreen {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
            case .loaded:
                layout
            case .failed(let message):
                DSText(message, style: .footnote, color: DSColor.destructive)
                    .padding(DSSpacing.medium)
            }
        }
        .task { await viewModel.load() }
    }

    @ViewBuilder private var layout: some View {
        if sizeClass == .regular {
            GamePadLayout(viewModel: viewModel)
        } else {
            GamePhoneLayout(viewModel: viewModel)
        }
    }
}

#Preview("iPhone") {
    NavigationStack {
        GameView(dependencies: GameDependencies(drawnNumbers: gamePreviewDrawnNumbers))
    }
}

#Preview("iPad", traits: .landscapeLeft) {
    NavigationStack {
        GameView(dependencies: GameDependencies(drawnNumbers: gamePreviewDrawnNumbers))
    }
    .environment(\.horizontalSizeClass, .regular)
}
