import AVFoundation

/// Plays the sound of the drum spinning, `Resources/Sounds/bombo-girando.wav`, which lasts as long as a spin.
/// It uses the playback audio session, mixed with other audio, so it sounds also with the silent switch on.
@MainActor
final class DSDrumSound {
    /// One player for every drum, loaded the first time a drum spins.
    static let shared = DSDrumSound()

    private let player: AVAudioPlayer?

    private init() {
        Self.usePlaybackSession()
        let url = Bundle.module.url(forResource: "bombo-girando", withExtension: "wav")
        player = url.flatMap { try? AVAudioPlayer(contentsOf: $0) }
        player?.prepareToPlay()
    }

    /// Plays the sound from the start, also when the previous spin is still sounding.
    func play() {
        guard let player else { return }
        player.currentTime = 0
        player.play()
    }

    /// Sets the playback category once, so the drum sounds also with the silent switch on: the sound is part
    /// of calling the game in the room. It mixes with other audio instead of stopping it. The player
    /// activates the session itself when it plays, so it is not activated by hand on every spin.
    private static func usePlaybackSession() {
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
        #endif
    }
}
