import SwiftUI

/// The bingo drum: a golden cage with balls inside. Each time `turns` grows, the cage and the balls spin for
/// three seconds, with the sound of the drum. With Reduce Motion the drum does not spin, but it still sounds.
/// It is decorative, so VoiceOver skips it.
public struct DSDrum: View {
    private let radius: CGFloat
    private let turns: Int
    private let playsSound: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - radius: Radius of the cage: 150 pt on iPhone, 170 pt on iPad and 260 pt on a TV.
    ///   - turns: Number of spins so far. Increase it by one to spin the drum once.
    ///   - playsSound: Whether each spin plays the sound of the drum. Turn it off on a second drum that shows
    ///     the same game, such as the one on the TV, so the sound does not play twice.
    public init(radius: CGFloat, turns: Int = 0, playsSound: Bool = true) {
        self.radius = radius
        self.turns = turns
        self.playsSound = playsSound
    }

    /// Time a spin takes, so callers can wait for it to end.
    public static let spinDuration: Duration = .seconds(3)

    public var body: some View {
        ZStack {
            ForEach(DrumBall.all) { ball in
                DSBallSphere(tone: DSBallTone(number: ball.number))
                    .frame(width: radius * DrumBall.radius * 2, height: radius * DrumBall.radius * 2)
                    .position(x: center.x + ball.offset.x * radius, y: center.y + ball.offset.y * radius)
                    .rotationEffect(.degrees(Double(turns * ball.turns) * 360))
            }
            cage
        }
        .frame(width: center.x * 2, height: center.y * 2)
        .animation(reduceMotion ? nil : .timingCurve(0.5, 0, 0.25, 1, duration: 3), value: turns)
        .onChange(of: turns) { oldTurns, newTurns in
            if playsSound && newTurns > oldTurns {
                DSDrumSound.shared.play()
            }
        }
        .accessibilityHidden(true)
    }

    /// Centre of the cage. The axis sticks out 8 % of the radius on each side.
    private var center: CGPoint {
        CGPoint(x: radius * 1.08, y: radius)
    }

    private var cage: some View {
        let thick = radius * 0.03
        let thin = radius * 0.022
        return ZStack {
            Circle()
                .stroke(DSPalette.cromo400, lineWidth: thick)
                .frame(width: radius * 2, height: radius * 2)
            Ellipse()
                .stroke(DSPalette.cromo400.opacity(0.7), lineWidth: thin)
                .frame(width: radius * 0.9, height: radius * 2)
                .rotationEffect(.degrees(Double(turns) * 360))
            Ellipse()
                .stroke(DSPalette.cromo400.opacity(0.7), lineWidth: thin)
                .frame(width: radius * 2, height: radius * 0.4)
            Capsule()
                .fill(DSPalette.cromo400)
                .frame(width: center.x * 2, height: thick)
        }
    }
}

/// One of the balls drawn inside the drum: its place, as a fraction of the radius from the centre, the number
/// that gives its tone and how many times it turns, and in which direction, in each spin.
private struct DrumBall: Identifiable {
    static let radius: CGFloat = 0.17

    static let all: [DrumBall] = [
        DrumBall(id: 0, offset: CGPoint(x: -0.52, y: 0.62), number: 5, turns: 1),
        DrumBall(id: 1, offset: CGPoint(x: -0.18, y: 0.62), number: 35, turns: -1),
        DrumBall(id: 2, offset: CGPoint(x: 0.16, y: 0.62), number: 15, turns: 2),
        DrumBall(id: 3, offset: CGPoint(x: 0.5, y: 0.62), number: 45, turns: -2),
        DrumBall(id: 4, offset: CGPoint(x: -0.36, y: 0.33), number: 25, turns: 1),
        DrumBall(id: 5, offset: CGPoint(x: -0.02, y: 0.33), number: 55, turns: 2),
        DrumBall(id: 6, offset: CGPoint(x: 0.32, y: 0.33), number: 65, turns: -1),
        DrumBall(id: 7, offset: CGPoint(x: -0.2, y: 0.02), number: 75, turns: 3),
        DrumBall(id: 8, offset: CGPoint(x: 0.14, y: 0.02), number: 15, turns: -2),
        DrumBall(id: 9, offset: CGPoint(x: -0.45, y: -0.25), number: 45, turns: -1)
    ]

    let id: Int
    let offset: CGPoint
    let number: Int
    let turns: Int
}

#Preview {
    @Previewable @State var turns = 0
    VStack(spacing: DSSpacing.large) {
        DSDrum(radius: 150, turns: turns)
        DSButton("Girar", systemImage: "arrow.clockwise") { turns += 1 }
    }
    .padding()
    .background(DSPalette.noche900)
    .environment(\.colorScheme, .dark)
}
