import Foundation
@testable import BingoghData
import Testing

struct GameRepositoryTests {
    private struct SampleGame: GameRequestProtocol {
        let drawnNumbers: [Int]
    }

    /// Each test uses its own folder: tests run in parallel and would overwrite each other's file.
    private func makeRepository(folder: String = #function) -> GameRepository {
        GameRepository(storage: GameStorage(store: JSONFileStore(folder: "GameRepositoryTests-\(folder)")))
    }

    @Test func savesAndReadsTheDrawnNumbersInOrder() async throws {
        let repository = makeRepository()
        try await repository.save(SampleGame(drawnNumbers: [42, 7, 75, 1]))
        #expect(try await repository.fetch().drawnNumbers == [42, 7, 75, 1])
        try await repository.delete()
    }

    @Test func fetchThrowsNotFoundAfterDelete() async throws {
        let repository = makeRepository()
        try await repository.save(SampleGame(drawnNumbers: [3]))
        try await repository.delete()
        await #expect(throws: LocalStoreError.notFound(GameStorage.key)) {
            try await repository.fetch()
        }
    }
}
