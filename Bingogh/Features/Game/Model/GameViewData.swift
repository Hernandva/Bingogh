import Foundation

/// Display-ready data of Game. The view model owns it as a variable and adds each use case result
/// to its own field, so a new result never erases the rest of the data.
struct GameViewData: Equatable, Sendable {
    /// Balls in the drum: the game goes from 1 to 90.
    static let totalBalls = 90

    /// Balls drawn so far in the game, from `GameUseCase`.
    struct Draw: Equatable, Sendable {
        /// A game with no balls drawn yet.
        static let empty = Draw(drawnNumbers: [])

        /// Numbers drawn so far, in the order they came out of the drum.
        let drawnNumbers: [Int]

        /// The same numbers as a set, for the caller board.
        var drawnSet: Set<Int> { Set(drawnNumbers) }
        /// The last ball drawn, ringed on the board.
        var lastNumber: Int? { drawnNumbers.last }
        /// How many balls have been drawn, for the "24 de 90" counter.
        var drawnCount: Int { drawnNumbers.count }
    }

    /// Result of `GameUseCase`: the balls drawn so far, or `nil` until it loads.
    var draw: Draw?
}
