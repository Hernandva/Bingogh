import Foundation

/// Public data the Game repository returns when it reads: the saved game in progress.
/// GameResponseDAO conforms to it.
public protocol GameResponseProtocol: Sendable {
    /// Numbers drawn so far, in the order they came out of the drum.
    var drawnNumbers: [Int] { get }
}
