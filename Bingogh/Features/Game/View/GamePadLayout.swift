import BingoghUI
import SwiftUI

/// iPad layout of the game. In landscape, the drum and its controls on the left and the caller board, in
/// 10 columns of 9, on the right. In portrait, the drum and its controls above the board.
struct GamePadLayout: View {
    let viewModel: GameViewModel

    var body: some View {
        GeometryReader { proxy in
            if proxy.size.width > proxy.size.height {
                landscape
            } else {
                portrait
            }
        }
    }

    private var landscape: some View {
        HStack(spacing: DSSpacing.xLarge + DSSpacing.medium) {
            VStack(spacing: DSSpacing.xLarge) {
                Spacer(minLength: 0)
                GameDrumStage(viewModel: viewModel, radius: 170, ballDiameter: 260)
                Spacer(minLength: 0)
                controls
            }
            .padding(.bottom, DSSpacing.large)
            board
        }
        .padding(.leading, DSSpacing.xLarge)
        .padding([.trailing, .bottom], DSSpacing.xLarge)
        .padding(.top, DSSpacing.small)
    }

    private var portrait: some View {
        VStack(spacing: DSSpacing.xLarge) {
            HStack(spacing: DSSpacing.xLarge) {
                GameDrumStage(viewModel: viewModel, radius: 150, ballDiameter: 230)
                VStack(spacing: DSSpacing.large) {
                    DSText(GameCounter.text(for: viewModel.viewData.draw), style: .counter)
                    controls
                }
            }
            board
        }
        .padding([.horizontal, .bottom], DSSpacing.xLarge)
        .padding(.top, DSSpacing.small)
    }

    private var controls: some View {
        GameControls(viewModel: viewModel)
            .frame(width: 380)
    }

    private var board: some View {
        GameCallerBoard(draw: viewModel.viewData.draw, layout: .landscape, size: .regular, review: viewModel)
    }
}

#Preview(traits: .landscapeLeft) {
    let dependencies = GameDependencies(drawnNumbers: gamePreviewDrawnNumbers)
    let viewModel = dependencies.resolveViewModel()
    DSGameScreen {
        GamePadLayout(viewModel: viewModel)
    }
    .task { await viewModel.load() }
}
