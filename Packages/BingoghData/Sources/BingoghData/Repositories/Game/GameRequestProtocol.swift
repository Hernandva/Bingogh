import Foundation

/// Public data the app saves with the Game repository: the game in progress.
/// GameRequestDAO turns it into the stored format.
public protocol GameRequestProtocol: Sendable {
    /// Numbers drawn so far, in the order they came out of the drum.
    var drawnNumbers: [Int] { get }
}
