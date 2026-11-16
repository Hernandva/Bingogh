import BingoghUI
import SwiftUI

/// iPhone layout of the game: "Bombo / Tablero" on top and, below, either the drum with the counter and the
/// controls, or the caller board in 9 columns of 10.
struct GamePhoneLayout: View {
    @Bindable var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: DSSpacing.medium) {
            DSSegmentedControl(
                selection: $viewModel.selectedPanel,
                options: [
                    .init(.drum, title: String(localized: "game.panel.drum")),
                    .init(.board, title: String(localized: "game.panel.board"))
                ]
            )
            switch viewModel.selectedPanel {
            case .drum:
                drumPanel
            case .board:
                GameCallerBoard(draw: viewModel.viewData.draw, layout: .portrait, size: .compact)
            }
        }
        .padding(.horizontal, DSSpacing.medium)
        .padding(.bottom, DSSpacing.small)
    }

    private var drumPanel: some View {
        VStack(spacing: DSSpacing.large) {
            Spacer(minLength: 0)
            GameDrumStage(viewModel: viewModel, radius: 150, ballDiameter: 180)
            Spacer(minLength: 0)
            DSText(GameCounter.text(for: viewModel.viewData.draw), style: .counter)
            GameControls(viewModel: viewModel)
        }
    }
}

#Preview {
    let dependencies = GameDependencies(drawnNumbers: gamePreviewDrawnNumbers)
    let viewModel = dependencies.resolveViewModel()
    DSGameScreen {
        GamePhoneLayout(viewModel: viewModel)
    }
    .task { await viewModel.load() }
}
