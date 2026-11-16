import Foundation

/// Stored format of the Game data, read by the repository. Internal to BingoghData:
/// the app only sees GameResponseProtocol. Keep its coding keys equal to GameRequestDAO's.
struct GameResponseDAO: Decodable, Sendable, GameResponseProtocol {
    let drawnNumbers: [Int]
}
