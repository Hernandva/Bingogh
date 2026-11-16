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
    /// The ball that has just come out, shown over the drum for a few seconds, or `nil`.
    private(set) var shownBall: Int?

    /// `true` once all 90 balls are out: "Girar" turns into "Partida nueva".
    var isGameOver: Bool {
        (viewData.draw?.drawnCount ?? 0) >= GameViewData.totalBalls
    }

    /// "Girar" works while the drum is still and there are balls left in it.
    var canSpin: Bool {
        !isSpinning && !isGameOver
    }

    /// Time a spin of the drum takes, the same as the `DSDrum` animation.
    private static let spinDuration: Duration = .seconds(3)
    /// How long the ball that came out stays over the drum, unless "Girar" is pressed again.
    private static let ballDisplayDuration: Duration = .seconds(5)

    private let useCase: any GameUseCaseProtocol
    private var hideBallTask: Task<Void, Never>?

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

    /// "Girar": picks a ball that has not come out yet and spins the drum. When the spin ends, the ball is
    /// added to the board and shown over the drum for five seconds, and the game is saved.
    func spin() async {
        guard canSpin, let draw = viewData.draw, let number = useCase.drawBall(from: draw) else { return }
        hideBall()
        isSpinning = true
        drumTurns += 1
        try? await Task.sleep(for: Self.spinDuration)
        let updatedDraw = GameViewData.Draw(drawnNumbers: draw.drawnNumbers + [number])
        viewData.draw = updatedDraw
        isSpinning = false
        show(number)
        // A failed save must not stop the game in the room: the ball stays drawn on screen, and the next
        // ball saves the whole game again.
        try? await useCase.save(updatedDraw)
    }

    /// "Partida nueva", once all 90 balls are out: empties the board and the drum and deletes the saved game.
    func startNewGame() async {
        hideBall()
        viewData.draw = .empty
        // As with saving, a failed delete must not block the new game on screen: the first ball drawn
        // saves the new game over the old one.
        try? await useCase.deleteSavedGame()
    }

    /// "Cantar en voz alta": reading the last ball aloud is not part of the UI yet.
    func singLastBall() {}

    private func show(_ number: Int) {
        shownBall = number
        hideBallTask = Task { [weak self] in
            try? await Task.sleep(for: Self.ballDisplayDuration)
            guard !Task.isCancelled else { return }
            self?.shownBall = nil
        }
    }

    private func hideBall() {
        hideBallTask?.cancel()
        hideBallTask = nil
        shownBall = nil
    }
}
