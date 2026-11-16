import BingoghData
import BingoghUI
import SwiftUI

/// The caller board of the game with its localised title and counter.
struct GameCallerBoard: View {
    let draw: GameViewData.Draw?
    let layout: DSCallerBoard.Layout
    let size: DSCallerBoard.Size

    var body: some View {
        DSCallerBoard(
            title: String(localized: "game.board.title"),
            counter: GameCounter.text(for: draw),
            drawnNumbers: draw?.drawnSet ?? [],
            lastNumber: draw?.lastNumber,
            layout: layout,
            size: size
        )
    }
}

/// "Girar" and "Cantar en voz alta", under the drum on iPhone and iPad.
struct GameControls: View {
    let viewModel: GameViewModel

    var body: some View {
        HStack(spacing: DSSpacing.espacioS) {
            DSButton(systemImage: "arrow.clockwise") {
                Task { await viewModel.spin() }
            }
            .localized("game.spin")
            .disabled(viewModel.isSpinning)
            DSIconButton(
                systemImage: "mic",
                accessibilityLabel: String(localized: "game.singAloud")
            ) {
                viewModel.singLastBall()
            }
        }
    }
}

/// The "24 de 90" counter: balls drawn out of the 90 in the drum.
enum GameCounter {
    static func text(for draw: GameViewData.Draw?) -> String {
        String(format: String(localized: "game.counter"), draw?.drawnCount ?? 0, GameViewData.totalBalls)
    }
}

#if DEBUG
/// Game repository for the previews: a game in progress with the 24 balls of the design.
struct GamePreviewRepository: GameRepositoryProtocol {
    private struct Response: GameResponseProtocol {
        let drawnNumbers = [
            3, 41, 12, 22, 52, 63, 44, 84, 35, 56, 66, 7,
            27, 87, 18, 38, 58, 68, 9, 29, 49, 79, 70, 47
        ]
    }

    func fetch() async throws -> any GameResponseProtocol { Response() }
    func save(_ request: some GameRequestProtocol) async throws {}
    func delete() async throws {}
}
#endif
