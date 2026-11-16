import BingoghData
import Foundation

protocol GameUseCaseProtocol: Sendable {
    /// Returns the balls drawn so far in the game that Home opened: the saved game, or none for a new game.
    /// The view model adds it to `GameViewData.draw`.
    func execute() async throws -> GameViewData.Draw
}

/// Business logic of Game. The game to play comes from Home through `GameDependencies`, so the screen never
/// reads a saved game that "Partida nueva" is deleting. The Game repository, stored on the device, is kept for
/// saving each ball drawn once drawing is implemented.
struct GameUseCase: GameUseCaseProtocol {
    private let startingDraw: GameViewData.Draw
    private let repository: any GameRepositoryProtocol

    /// Receives only the container and resolves what it needs from it.
    /// `GameDependencies` lives on the main actor, so this init does too.
    @MainActor
    init(dependencies: GameDependencies) {
        self.startingDraw = dependencies.resolveStartingDraw()
        self.repository = dependencies.resolveRepository()
    }

    /// Checks the game that Home passed and returns only the balls the caller board can show: numbers from
    /// 1 to 90, each once, in the order they were drawn. A saved file that was edited or damaged never fills
    /// a square that does not exist or counts a ball twice.
    func execute() async throws -> GameViewData.Draw {
        GameViewData.Draw(drawnNumbers: Self.validNumbers(in: startingDraw.drawnNumbers))
    }
}

private extension GameUseCase {
    static func validNumbers(in drawnNumbers: [Int]) -> [Int] {
        var seen = Set<Int>()
        return drawnNumbers.filter { number in
            (1...GameViewData.totalBalls).contains(number) && seen.insert(number).inserted
        }
    }
}
