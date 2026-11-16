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

/// The drum, or the ball that has just come out in its place. When the spin ends the ball replaces the drum
/// completely until the view model hides it, five seconds later or when "Girar" is pressed again; then the
/// drum comes back. The drum keeps its place while hidden, so nothing else on screen moves. VoiceOver
/// announces the ball.
struct GameDrumStage: View {
    let viewModel: GameViewModel
    let radius: CGFloat
    let ballDiameter: CGFloat
    var playsSound = true

    var body: some View {
        DSDrum(radius: radius, turns: viewModel.drumTurns, playsSound: playsSound)
            .opacity(viewModel.shownBall == nil ? 1 : 0)
            .scaleEffect(viewModel.shownBall == nil ? 1 : 0.85)
            .overlay {
                if let number = viewModel.shownBall {
                    DSBall(number: number, diameter: ballDiameter)
                        .transition(.scale(scale: 0.3).combined(with: .opacity))
                }
            }
            .animation(.spring(duration: 0.4, bounce: 0.35), value: viewModel.shownBall)
            .onChange(of: viewModel.shownBall) { _, number in
                guard let number, playsSound else { return }
                let format = String(localized: "game.ballAnnouncement")
                AccessibilityNotification.Announcement(String(format: format, number)).post()
            }
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
