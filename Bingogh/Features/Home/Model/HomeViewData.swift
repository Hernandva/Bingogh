import Foundation

/// Display-ready data of Home. The view model owns it as a variable and adds each use case result
/// to its own field, so a new result never erases the rest of the data.
struct HomeViewData: Equatable, Sendable {
    /// A game that Home hands to the next screen: the saved one, or an empty one for a new game.
    struct SavedGame: Hashable, Sendable {
        /// A game with no balls drawn yet.
        static let empty = SavedGame(drawnNumbers: [])

        /// Numbers drawn so far, in the order they came out of the drum.
        let drawnNumbers: [Int]
    }

    /// Result of `SavedGameUseCase`: the saved game, or `nil` when there is none (or until it loads).
    var savedGame: SavedGame?

    /// "Continuar partida" is shown only when there is a game to resume.
    var canContinueGame: Bool { savedGame != nil }
}
