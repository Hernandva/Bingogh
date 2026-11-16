import Foundation
import BingoghData

/// Dependency injection container of Game: the only place where its concrete types are built.
/// View, ViewModel and UseCase receive it in their `init(dependencies:)` and call the `resolve` functions they need.
@MainActor
final class GameDependencies {
    private let repository: any GameRepositoryProtocol

    init(repository: any GameRepositoryProtocol = GameRepository()) {
        self.repository = repository
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
