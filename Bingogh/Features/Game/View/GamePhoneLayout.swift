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
                GameCallerBoard(draw: viewModel.viewData.draw, layout: .portrait, size: .compact, review: viewModel)
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
            // "Repaso" also sits beside this counter: the review plays on this panel, so "Detener" must be
            // reachable here too, not only on the board.
            HStack(spacing: DSSpacing.small) {
                DSText(GameCounter.text(for: viewModel.viewData.draw), style: .counter)
                GameReviewButton(viewModel: viewModel)
            }
            GameControls(viewModel: viewModel)
        }
    }
}

#Preview {
    let dependencies = GameDependencies(drawnNumbers: [
        3, 41, 12, 22, 52, 63, 44, 84, 35, 56, 66, 7,
        27, 87, 18, 38, 58, 68, 9, 29, 49, 79, 70, 47
    ])
    let viewModel = dependencies.resolveViewModel()
    DSGameScreen {
        GamePhoneLayout(viewModel: viewModel)
    }
    .task { await viewModel.load() }
}
