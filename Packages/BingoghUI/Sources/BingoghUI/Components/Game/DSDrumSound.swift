import AVFoundation

/// Plays the sound of the drum spinning, `Resources/Sounds/bombo-girando.wav`, which lasts as long as a spin.
/// It uses the ambient audio session, so it mixes with other audio and follows the silent switch.
@MainActor
final class DSDrumSound {
    /// One player for every drum, loaded the first time a drum spins.
    static let shared = DSDrumSound()

    private let player: AVAudioPlayer?

    private init() {
        let url = Bundle.module.url(forResource: "bombo-girando", withExtension: "wav")
        player = url.flatMap { try? AVAudioPlayer(contentsOf: $0) }
        player?.prepareToPlay()
    }

    /// Plays the sound from the start, also when the previous spin is still sounding.
    func play() {
        guard let player else { return }
        Self.activateSession()
        player.currentTime = 0
        player.play()
    }

    private static func activateSession() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient)
        try? session.setActive(true)
        #endif
    }
}
