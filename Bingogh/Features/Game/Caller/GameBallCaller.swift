import AVFoundation

/// Reads the balls aloud, as a bingo caller does.
@MainActor
protocol GameBallCallerProtocol: AnyObject {
    /// Reads the ball. From 10: the whole number, its digits one by one and the whole number again
    /// ("cuarenta y siete… cuatro, siete… cuarenta y siete"). From 1 to 9: the number once ("siete").
    /// It cuts off any reading still in progress and returns when this reading ends, or as soon as it is cut
    /// off by `stop()` or by another call.
    func call(_ number: Int) async
    /// Stops reading at once.
    func stop()
}

/// Reads the balls with the system voice in the app's language. It uses the playback audio session mixed
/// with other audio, like the drum, so it is heard also with the silent switch on.
@MainActor
final class GameBallCaller: NSObject, GameBallCallerProtocol {
    /// Pause after the whole number and after the digits.
    private static let pause: TimeInterval = 0.5

    private let synthesizer = AVSpeechSynthesizer()
    private let voice: AVSpeechSynthesisVoice?
    /// Resumes the `call(_:)` that is waiting for its reading to end.
    private var finishReading: CheckedContinuation<Void, Never>?
    /// The last utterance of the reading in progress: when it finishes, the reading has ended.
    private var lastUtterance: ObjectIdentifier?

    override init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
        let language = Bundle.main.preferredLocalizations.first ?? "es"
        voice = AVSpeechSynthesisVoice(language: language)
        super.init()
        synthesizer.delegate = self
    }

    func call(_ number: Int) async {
        stop()
        let texts = Self.reading(of: number)
        let utterances = texts.enumerated().map { index, text in
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = voice
            utterance.postUtteranceDelay = index < texts.count - 1 ? Self.pause : 0
            return utterance
        }
        lastUtterance = utterances.last.map(ObjectIdentifier.init)
        utterances.forEach(synthesizer.speak)
        await withCheckedContinuation { finishReading = $0 }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        endReading()
    }

    /// What is read for a ball. From 1 to 9, the number once ("siete"). From 10, the whole number, its
    /// digits and the whole number again ("cuarenta y siete", "cuatro, siete", "cuarenta y siete").
    private static func reading(of number: Int) -> [String] {
        let whole = String(number)
        guard number >= 10 else { return [whole] }
        let digits = whole.map(String.init).joined(separator: ", ")
        return [whole, digits, whole]
    }

    private func endReading() {
        lastUtterance = nil
        finishReading?.resume()
        finishReading = nil
    }

    private func utteranceFinished(_ utterance: ObjectIdentifier) {
        if utterance == lastUtterance {
            endReading()
        }
    }
}

extension GameBallCaller: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let finished = ObjectIdentifier(utterance)
        Task { @MainActor in
            self.utteranceFinished(finished)
        }
    }
}
