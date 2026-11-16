import BingoghData
import Foundation

protocol SavedGameUseCaseProtocol: Sendable {
    /// Returns the saved game in progress, or `nil` when there is none.
    /// The view model adds it to `HomeViewData.savedGame`.
    func execute() async throws -> HomeViewData.SavedGame?
    /// Deletes the saved game, if there is one.
    func deleteSavedGame() async throws
}

/// Reads and deletes the game in progress in the Game repository.
struct SavedGameUseCase: SavedGameUseCaseProtocol {
    private let repository: any GameRepositoryProtocol

    /// Receives only the container and resolves what it needs from it.
    /// `HomeDependencies` lives on the main actor, so this init does too.
    @MainActor
    init(dependencies: HomeDependencies) {
        self.repository = dependencies.resolveRepository()
    }

    func execute() async throws -> HomeViewData.SavedGame? {
        do {
            let response = try await repository.fetch()
            return HomeViewData.SavedGame(drawnNumbers: response.drawnNumbers)
        } catch LocalStoreError.notFound {
            return nil
        }
    }

    func deleteSavedGame() async throws {
        try await repository.delete()
    }
}
