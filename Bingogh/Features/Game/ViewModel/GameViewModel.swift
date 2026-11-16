import Foundation
import Observation

@MainActor
@Observable
final class GameViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    /// The two halves of the game on iPhone, where only one fits on screen at a time.
    enum Panel: Hashable {
        case drum
        case board
    }

    private(set) var state: State = .idle
    /// Data of the screen. Each use case result updates only its own field.
    private(set) var viewData = GameViewData()
    /// Panel shown on iPhone: "Bombo" or "Tablero".
    var selectedPanel: Panel = .drum
    /// Spins of the drum so far. Each spin makes `DSDrum` turn once.
    private(set) var drumTurns = 0
    /// `true` while the drum spins, so "Girar" cannot start another spin.
    private(set) var isSpinning = false

    /// Time a spin of the drum takes, the same as the `DSDrum` animation.
    private static let spinDuration: Duration = .seconds(3)

    private let useCase: any GameUseCaseProtocol

    /// Receives only the container and resolves what it needs from it.
    init(dependencies: GameDependencies) {
        self.useCase = dependencies.resolveUseCase()
    }

    func load() async {
        state = .loading
        do {
            viewData.draw = try await useCase.execute()
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /// "Girar": spins the drum once. Drawing the ball out of it is not part of the UI yet.
    func spin() async {
        guard !isSpinning else { return }
        isSpinning = true
        drumTurns += 1
        try? await Task.sleep(for: Self.spinDuration)
        isSpinning = false
    }

    /// "Cantar en voz alta": reading the last ball aloud is not part of the UI yet.
    func singLastBall() {}
}
