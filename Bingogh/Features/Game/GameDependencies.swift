import Foundation
import BingoghData

/// Dependency injection container of Game: the only place where its concrete types are built.
/// View, ViewModel and UseCase receive it in their `init(dependencies:)` and call the `resolve` functions they need.
@MainActor
final class GameDependencies {
    private let repository: any GameRepositoryProtocol
    private let startingDraw: GameViewData.Draw

    /// - Parameters:
    ///   - drawnNumbers: Balls already drawn in the game that Home opens: the saved game, or none for a new one.
    ///   - repository: Where the game in progress is stored.
    init(drawnNumbers: [Int] = [], repository: any GameRepositoryProtocol = GameRepository()) {
        self.startingDraw = GameViewData.Draw(drawnNumbers: drawnNumbers)
        self.repository = repository
    }

    func resolveStartingDraw() -> GameViewData.Draw {
        startingDraw
    }

    func resolveRepository() -> any GameRepositoryProtocol {
        repository
    }

    func resolveUseCase() -> any GameUseCaseProtocol {
        GameUseCase(dependencies: self)
    }

    func resolveViewModel() -> GameViewModel {
        GameViewModel(dependencies: self)
    }
}
