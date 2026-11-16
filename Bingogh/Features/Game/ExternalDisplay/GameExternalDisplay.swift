import Observation

/// The game shown on the external display (a TV over AirPlay). The Game screen registers its view model while
/// it is on screen, and the TV, which runs in its own scene, reads the same view model, so both always show
/// the same drum, ball and board.
@MainActor
@Observable
final class GameExternalDisplay {
    /// One for the whole app: the iPhone or iPad scene writes it and the TV scene reads it.
    static let shared = GameExternalDisplay()

    /// The game on screen on the iPhone or iPad, or `nil` when none is open.
    private(set) var game: GameViewModel?

    /// Shows this game on the TV.
    func show(_ game: GameViewModel) {
        self.game = game
    }

    /// Stops showing this game on the TV, unless another game has replaced it already.
    func hide(_ game: GameViewModel) {
        if self.game === game {
            self.game = nil
        }
    }
}
