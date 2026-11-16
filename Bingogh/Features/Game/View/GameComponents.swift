import BingoghUI
import SwiftUI

/// The caller board of the game with its localised title and counter. On iPhone and iPad, `review` adds the
/// "Repaso" button after the counter, which turns into "Detener" during the review. The TV has no buttons.
struct GameCallerBoard: View {
    let draw: GameViewData.Draw?
    let layout: DSCallerBoardLayout
    let size: DSCallerBoardSize
    var review: GameViewModel?

    var body: some View {
        DSCallerBoard(
            title: String(localized: "game.board.title"),
            counter: GameCounter.text(for: draw),
            drawnNumbers: draw?.drawnSet ?? [],
            lastNumber: draw?.lastNumber,
            layout: layout,
            size: size
        ) {
            if let review {
                GameReviewButton(viewModel: review)
            }
        }
    }
}

/// "Repaso" (↺) starts reviewing the balls drawn so far; during the review it turns into "Detener" (■).
struct GameReviewButton: View {
    let viewModel: GameViewModel

    var body: some View {
        if viewModel.isReviewing {
            DSIconButton(
                systemImage: "stop.fill",
                accessibilityLabel: String(localized: "game.stopReview"),
                size: .small
            ) {
                viewModel.stopReview()
            }
        } else {
            DSIconButton(
                systemImage: "arrow.counterclockwise",
                accessibilityLabel: String(localized: "game.review"),
                size: .small
            ) {
                viewModel.startReview()
            }
            .disabled(!viewModel.canReview)
        }
    }
}

/// The drum, or in its place the ball that has just come out or the one being reviewed. When the spin ends the ball replaces the drum
/// completely until the view model hides it, five seconds later or when "Girar" is pressed again; then the
/// drum comes back. The drum keeps its place while hidden, so nothing else on screen moves. The view model
/// reads each ball aloud.
struct GameDrumStage: View {
    let viewModel: GameViewModel
    let radius: CGFloat
    let ballDiameter: CGFloat
    var playsSound = true

    var body: some View {
        DSDrum(radius: radius, turns: viewModel.drumTurns, playsSound: playsSound)
            .opacity(viewModel.displayedBall == nil ? 1 : 0)
            .scaleEffect(viewModel.displayedBall == nil ? 1 : 0.85)
            .overlay {
                if let number = viewModel.displayedBall {
                    DSBall(number: number, diameter: ballDiameter)
                        .id(number)
                        .transition(.scale(scale: 0.3).combined(with: .opacity))
                }
            }
            .animation(.spring(duration: 0.4, bounce: 0.35), value: viewModel.displayedBall)
    }
}

/// "Girar" and "Cantar en voz alta", under the drum on iPhone and iPad. Once all 90 balls are out, "Girar"
/// turns into "Partida nueva", which starts the game again.
struct GameControls: View {
    let viewModel: GameViewModel

    var body: some View {
        HStack(spacing: DSSpacing.espacioS) {
            if viewModel.isGameOver {
                DSButton(systemImage: "plus") {
                    Task { await viewModel.startNewGame() }
                }
                .localized("game.newGame")
                .disabled(viewModel.isReviewing)
            } else {
                DSButton(systemImage: "arrow.clockwise") {
                    Task { await viewModel.spin() }
                }
                .localized("game.spin")
                .disabled(!viewModel.canSpin)
            }
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
/// A game in progress with the 24 balls of the design, for the previews.
let gamePreviewDrawnNumbers = [
    3, 41, 12, 22, 52, 63, 44, 84, 35, 56, 66, 7,
    27, 87, 18, 38, 58, 68, 9, 29, 49, 79, 70, 47
]
#endif
