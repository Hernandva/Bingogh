import BingoghData
import Foundation

protocol GameUseCaseProtocol: Sendable {
    /// Returns the balls drawn so far in the saved game, or an empty draw when there is no saved game.
    /// The view model adds it to `GameViewData.draw`.
    func execute() async throws -> GameViewData.Draw
}

/// Business logic of Game: reads the game in progress from the Game repository, stored on the device, and
/// returns only the balls drawn so far, mapped out of the BingoghData types.
struct GameUseCase: GameUseCaseProtocol {
    private let repository: any GameRepositoryProtocol

    /// Receives only the container and resolves what it needs from it.
    /// `GameDependencies` lives on the main actor, so this init does too.
    @MainActor
    init(dependencies: GameDependencies) {
        self.repository = dependencies.resolveRepository()
    }

    func execute() async throws -> GameViewData.Draw {
        do {
            let response = try await repository.fetch()
            return GameViewData.Draw(drawnNumbers: response.drawnNumbers)
        } catch LocalStoreError.notFound {
            return .empty
        }
    }
}
