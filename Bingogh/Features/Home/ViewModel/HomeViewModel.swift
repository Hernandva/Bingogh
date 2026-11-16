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
    /// Game handed to the next screen by "Continuar partida" or "Partida nueva".
    private(set) var gameToPlay: HomeViewData.SavedGame?

    private let useCase: any GameUseCaseProtocol

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

    /// "Continuar partida": hands the saved game to the next screen.
    func continueGame() {
        guard let savedGame = viewData.savedGame else { return }
        open(savedGame)
    }

    /// "Partida nueva": deletes the saved game, if there is one, and hands an empty game to the next screen.
    func startNewGame() async {
        do {
            try await useCase.deleteSavedGame()
            viewData.savedGame = nil
            open(.empty)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    private func open(_ game: HomeViewData.SavedGame) {
        gameToPlay = game
        // Navigation to the game screen will be added later. When that feature exists, push it with
        // NavigationLink(value: HomeCoordinator.Route.<game>(game)) and pass it this game.
    }
}
