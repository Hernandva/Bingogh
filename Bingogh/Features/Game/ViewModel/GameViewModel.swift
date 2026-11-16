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
    /// The ball that has just come out, shown in place of the drum while it is read aloud, or `nil`.
    private(set) var shownBall: Int?
    /// `true` during "Repaso": the balls drawn so far replace the drum one by one, in order.
    private(set) var isReviewing = false
    /// The ball on screen during "Repaso".
    private(set) var reviewedBall: Int?
    /// Mute: the balls are not read aloud. It is not saved, so it is off every time the game opens.
    private(set) var isMuted = false

    /// The ball shown in place of the drum: the one being reviewed, or the one that has just come out.
    var displayedBall: Int? {
        isReviewing ? reviewedBall : shownBall
    }

    /// "Repaso" works while the drum is still and at least one ball has come out.
    var canReview: Bool {
        !isSpinning && (viewData.draw?.drawnCount ?? 0) > 0
    }

    /// `true` once all 90 balls are out: "Girar" turns into "Partida nueva".
    var isGameOver: Bool {
        (viewData.draw?.drawnCount ?? 0) >= GameViewData.totalBalls
    }

    /// "Girar" works while the drum is still and there are balls left in it.
    var canSpin: Bool {
        !isSpinning && !isGameOver && !isReviewing
    }

    /// Time a spin of the drum takes, the same as the `DSDrum` animation.
    private static let spinDuration: Duration = .seconds(3)
    /// How long a ball stays on screen while muted, when there is no reading to wait for.
    private static let mutedBallDuration: Duration = .seconds(3)

    private let useCase: any GameUseCaseProtocol
    private let externalDisplay: GameExternalDisplay
    private let ballCaller: any GameBallCallerProtocol
    private var hideBallTask: Task<Void, Never>?
    private var reviewTask: Task<Void, Never>?
    /// The ball that was showing when "Repaso" started, shown again when it stops.
    private var ballBeforeReview: Int?

    /// Receives only the container and resolves what it needs from it.
    init(dependencies: GameDependencies) {
        self.useCase = dependencies.resolveUseCase()
        self.externalDisplay = dependencies.resolveExternalDisplay()
        self.ballCaller = dependencies.resolveBallCaller()
    }

    /// The Game screen is on screen: the TV shows this game.
    func appear() {
        externalDisplay.show(self)
    }

    /// The Game screen has left: the TV goes back to the wordmark and any reading stops.
    func disappear() {
        externalDisplay.hide(self)
        ballCaller.stop()
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
    /// added to the board and shown in place of the drum while it is read aloud, and the game is saved.
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

    /// "Repaso": hides the drum and shows the balls drawn so far one by one, from lowest to highest, each
    /// one while it is read aloud. "Girar" is locked until it stops, either with "Detener" or after the last ball.
    func startReview() {
        guard canReview, !isReviewing, let numbers = viewData.draw?.drawnNumbers.sorted() else { return }
        ballBeforeReview = shownBall
        hideBall()
        isReviewing = true
        selectedPanel = .drum
        reviewTask = Task { [weak self] in
            for number in numbers {
                guard let self, !Task.isCancelled else { return }
                self.reviewedBall = number
                await self.present(number)
            }
            guard !Task.isCancelled else { return }
            self?.stopReview()
        }
    }

    /// "Detener": ends "Repaso" and leaves the game as it was before it started: the drum, or the ball that
    /// had just come out, shown and read again.
    func stopReview() {
        guard isReviewing else { return }
        reviewTask?.cancel()
        reviewTask = nil
        ballCaller.stop()
        isReviewing = false
        reviewedBall = nil
        if let ball = ballBeforeReview {
            show(ball)
        }
        ballBeforeReview = nil
    }

    /// The microphone button: turns mute on or off. Turning it on cuts off the reading in progress; the ball
    /// on screen then stays for the muted time.
    func toggleMute() {
        isMuted.toggle()
        if isMuted {
            ballCaller.stop()
        }
    }

    /// Shows the ball in place of the drum while it is presented; the drum comes back afterwards.
    private func show(_ number: Int) {
        hideBall()
        shownBall = number
        hideBallTask = Task { [weak self] in
            await self?.present(number)
            guard !Task.isCancelled else { return }
            self?.shownBall = nil
        }
    }

    /// Reads the ball aloud and returns when the reading ends. While muted, or if mute is turned on during the
    /// reading, it waits the muted time instead, so the ball is still seen.
    private func present(_ number: Int) async {
        if !isMuted {
            await ballCaller.call(number)
        }
        if isMuted, !Task.isCancelled {
            try? await Task.sleep(for: Self.mutedBallDuration)
        }
    }

    /// Hides the ball and cuts off its reading.
    private func hideBall() {
        hideBallTask?.cancel()
        hideBallTask = nil
        ballCaller.stop()
        shownBall = nil
    }
}
