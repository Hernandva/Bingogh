import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private(set) var state: State = .idle
    /// Data of the screen. Each use case result updates only its own field.
    private(set) var viewData = HomeViewData()

    private let useCase: any SavedGameUseCaseProtocol

    /// Receives only the container and resolves what it needs from it.
    init(dependencies: HomeDependencies) {
        self.useCase = dependencies.resolveUseCase()
    }

    func load() async {
        state = .loading
        do {
            viewData.savedGame = try await useCase.execute()
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /// "Partida nueva": deletes the saved game, if there is one. The button itself pushes
    /// `HomeCoordinator.Route.game(.empty)`, so the game screen opens with no balls drawn.
    func startNewGame() async {
        do {
            try await useCase.deleteSavedGame()
            viewData.savedGame = nil
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
