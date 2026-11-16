import Foundation
import BingoghData

/// Dependency injection container of Game: the only place where its concrete types are built.
/// View, ViewModel and UseCase receive it in their `init(dependencies:)` and call the `resolve` functions they need.
@MainActor
final class GameDependencies {
    private let repository: any GameRepositoryProtocol
    private let startingDraw: GameViewData.Draw
    private let externalDisplay: GameExternalDisplay
    private let ballCaller: any GameBallCallerProtocol

    /// - Parameters:
    ///   - drawnNumbers: Balls already drawn in the game that Home opens: the saved game, or none for a new one.
    ///   - repository: Where the game in progress is stored.
    ///   - externalDisplay: Where the game is shared with the TV over AirPlay.
    ///   - ballCaller: Reads each ball aloud.
    init(
        drawnNumbers: [Int] = [],
        repository: any GameRepositoryProtocol = GameRepository(),
        externalDisplay: GameExternalDisplay = .shared,
        ballCaller: any GameBallCallerProtocol = GameBallCaller()
    ) {
        self.startingDraw = GameViewData.Draw(drawnNumbers: drawnNumbers)
        self.repository = repository
        self.externalDisplay = externalDisplay
        self.ballCaller = ballCaller
    }

    func resolveBallCaller() -> any GameBallCallerProtocol {
        ballCaller
    }

    func resolveExternalDisplay() -> GameExternalDisplay {
        externalDisplay
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
