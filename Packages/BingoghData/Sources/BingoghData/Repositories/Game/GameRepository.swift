import Foundation

/// Public API of the Game repository. Features depend on this protocol, never on the concrete class.
public protocol GameRepositoryProtocol: Sendable {
    /// Reads the stored value. Throws `LocalStoreError.notFound` when nothing has been saved yet.
    func fetch() async throws -> any GameResponseProtocol
    /// Saves the value, replacing the previous one.
    func save(_ request: some GameRequestProtocol) async throws
    /// Removes the stored value.
    func delete() async throws
}

/// Keeps Game data on the device with JSON files, through `Local/GameStorage`.
/// Flow: GameRequestProtocol -> GameRequestDAO -> GameStorage
///       -> GameResponseDAO -> GameResponseProtocol.
public final class GameRepository: GameRepositoryProtocol {
    private let storage: any GameStorageProtocol

    public init() {
        storage = GameStorage()
    }

    /// Lets tests inject another storage.
    init(storage: any GameStorageProtocol) {
        self.storage = storage
    }

    public func fetch() async throws -> any GameResponseProtocol {
        guard let value = try await storage.load() else {
            throw LocalStoreError.notFound(GameStorage.key)
        }
        return value
    }

    public func save(_ request: some GameRequestProtocol) async throws {
        try await storage.save(GameRequestDAO(request))
    }

    public func delete() async throws {
        try await storage.remove()
    }
}
