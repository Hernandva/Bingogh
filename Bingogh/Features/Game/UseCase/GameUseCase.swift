import Foundation
import BingoghData

protocol GameUseCaseProtocol: Sendable {
    /// Returns only the data of the response. The view model adds it to its `GameViewData`.
    func execute() async throws -> GameViewData.Content
}

/// Business logic of Game: reads the Game repository, stored on the device, and returns only the data of
/// its response, mapped out of the BingoghData types. If the screen also writes data, add a use case that calls
/// `repository.save(_:)` with a type that conforms to GameRequestProtocol.
struct GameUseCase: GameUseCaseProtocol {
    private let repository: any GameRepositoryProtocol

    /// Receives only the container and resolves what it needs from it.
    /// `GameDependencies` lives on the main actor, so this init does too.
    @MainActor
    init(dependencies: GameDependencies) {
        self.repository = dependencies.resolveRepository()
    }

    func execute() async throws -> GameViewData.Content {
        let response = try await repository.fetch()
        return Self.content(from: response)
    }
}

private extension GameUseCase {
    /// Maps the fields of the Game response into the data the view model adds to its ViewData.
    static func content(from response: any GameResponseProtocol) -> GameViewData.Content {
        GameViewData.Content()
    }
}
