import BingoghData
import Foundation

/// Dependency injection container of Home: the only place where its concrete types are built.
/// View, ViewModel and UseCase receive it in their `init(dependencies:)` and call the `resolve` functions they need.
@MainActor
final class HomeDependencies {
    private let repository: any GameRepositoryProtocol

    init(repository: any GameRepositoryProtocol = GameRepository()) {
        self.repository = repository
    }

    func resolveRepository() -> any GameRepositoryProtocol {
        repository
    }

    func resolveUseCase() -> any SavedGameUseCaseProtocol {
        SavedGameUseCase(dependencies: self)
    }

    func resolveViewModel() -> HomeViewModel {
        HomeViewModel(dependencies: self)
    }
}
