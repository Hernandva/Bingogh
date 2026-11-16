import Foundation

/// Stored format of the Game data, written by the repository. Internal to BingoghData.
/// Keep its coding keys equal to GameResponseDAO's, so what is saved can be read back.
struct GameRequestDAO: Encodable, Sendable {
    let drawnNumbers: [Int]

    init(_ request: some GameRequestProtocol) {
        drawnNumbers = request.drawnNumbers
    }
}
