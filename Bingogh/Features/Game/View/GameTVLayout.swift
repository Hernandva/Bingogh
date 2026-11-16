import BingoghUI
import SwiftUI

/// TV layout of the game, for the external display over AirPlay (1920 × 1080): the drum on the left and the
/// caller board, in 10 columns of 9, on the right. It has no controls: the game is driven from the iPhone or
/// iPad, so it reads the same view model.
struct GameTVLayout: View {
    let viewModel: GameViewModel

    var body: some View {
        HStack(spacing: DSSpacing.espacioMega * 2) {
            DSDrum(radius: 260, turns: viewModel.drumTurns)
                .frame(maxHeight: .infinity)
            GameCallerBoard(draw: viewModel.viewData.draw, layout: .landscape, size: .television)
        }
        .padding(.leading, DSSpacing.espacioMega * 2)
        .padding(.trailing, DSSpacing.espacioMega + DSSpacing.xLarge)
        .padding(.vertical, DSSpacing.espacioXxxl + DSSpacing.small)
    }
}

#Preview(traits: .fixedLayout(width: 1920, height: 1080)) {
    let dependencies = GameDependencies(repository: GamePreviewRepository())
    let viewModel = dependencies.resolveViewModel()
    DSGameScreen {
        GameTVLayout(viewModel: viewModel)
    }
    .task { await viewModel.load() }
}
