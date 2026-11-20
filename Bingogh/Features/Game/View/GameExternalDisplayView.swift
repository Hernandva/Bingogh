import BingoghUI
import SwiftUI

/// Root view of the external display (a TV over AirPlay). While a game is open on the iPhone or iPad it
/// shows `GameTVLayout`, drawn at 1920 × 1080 and scaled to fit the TV. Otherwise it shows the wordmark over
/// the night sky.
struct GameExternalDisplayView: View {
    let display: GameExternalDisplay

    var body: some View {
        if let game = display.game, game.state == .loaded {
            DSGameScreen {
                GeometryReader { proxy in
                    GameTVLayout(viewModel: game)
                        .frame(width: Self.canvas.width, height: Self.canvas.height)
                        .scaleEffect(scale(for: proxy.size))
                        .frame(width: proxy.size.width, height: proxy.size.height)
                }
            }
        } else {
            DSNightScreen {
                DSWordmark().localized("home.title")
            }
        }
    }

    /// Size the TV layout is designed at.
    private static let canvas = CGSize(width: 1920, height: 1080)

    private func scale(for size: CGSize) -> CGFloat {
        min(size.width / Self.canvas.width, size.height / Self.canvas.height)
    }
}

#Preview(traits: .fixedLayout(width: 1280, height: 720)) {
    let display = GameExternalDisplay()
    let viewModel = GameDependencies(drawnNumbers: [
        3, 41, 12, 22, 52, 63, 44, 84, 35, 56, 66, 7,
        27, 87, 18, 38, 58, 68, 9, 29, 49, 79, 70, 47
    ], externalDisplay: display)
        .resolveViewModel()
    GameExternalDisplayView(display: display)
        .task {
            await viewModel.load()
            viewModel.appear()
        }
}
