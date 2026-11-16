import Foundation

/// On-device storage of Game: one value in JSON files under `GameStorage.key`.
protocol GameStorageProtocol: Sendable {
    /// The stored value, or `nil` when nothing has been saved yet.
    func load() async throws -> GameResponseDAO?
    /// Saves the value, replacing the previous one.
    func save(_ value: GameRequestDAO) async throws
    /// Removes the stored value.
    func remove() async throws
}

/// Writes the DAOs as JSON through a `LocalStore`. `GameRequestDAO` and `GameResponseDAO` must use the same
/// coding keys, so what is saved can be read back.
struct GameStorage: GameStorageProtocol {
    /// Do not change it once the app ships: the data saved under the old key would be lost.
    static let key = "bingoghData.game"

    private let store: any LocalStore

    init(store: any LocalStore = JSONFileStore()) {
        self.store = store
    }

    func load() async throws -> GameResponseDAO? {
        guard let data = try await store.read(key: Self.key) else { return nil }
        return try JSONDecoder().decode(GameResponseDAO.self, from: data)
    }

    func save(_ value: GameRequestDAO) async throws {
        try await store.write(JSONEncoder().encode(value), key: Self.key)
    }

    func remove() async throws {
        try await store.remove(key: Self.key)
    }
}
