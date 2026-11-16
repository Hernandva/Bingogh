import BingoghData
import Foundation

protocol GameUseCaseProtocol: Sendable {
    /// Returns the balls drawn so far in the game that Home opened: the saved game, or none for a new game.
    /// The view model adds it to `GameViewData.draw`.
    func execute() async throws -> GameViewData.Draw
    /// Picks at random a number from 1 to 90 that has not come out yet, or `nil` when all 90 are out.
    func drawBall(from draw: GameViewData.Draw) -> Int?
    /// Saves the game in progress, so "Continuar partida" resumes it with every ball drawn.
    func save(_ draw: GameViewData.Draw) async throws
    /// Deletes the saved game, when all 90 balls are out and a new game starts.
    func deleteSavedGame() async throws
}

/// Business logic of Game. The game to play comes from Home through `GameDependencies`, so the screen never
/// reads a saved game that "Partida nueva" is deleting. Each ball drawn is saved in the Game repository,
/// stored on the device.
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

    func drawBall(from draw: GameViewData.Draw) -> Int? {
        let drawn = draw.drawnSet
        return (1...GameViewData.totalBalls).filter { !drawn.contains($0) }.randomElement()
    }

    func save(_ draw: GameViewData.Draw) async throws {
        try await repository.save(GameRequest(drawnNumbers: draw.drawnNumbers))
    }

    func deleteSavedGame() async throws {
        try await repository.delete()
    }
}

/// The game in progress as the Game repository saves it.
private struct GameRequest: GameRequestProtocol {
    let drawnNumbers: [Int]
}

private extension GameUseCase {
    static func validNumbers(in drawnNumbers: [Int]) -> [Int] {
        var seen = Set<Int>()
        return drawnNumbers.filter { number in
            (1...GameViewData.totalBalls).contains(number) && seen.insert(number).inserted
        }
    }
}
