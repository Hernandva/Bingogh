import SwiftUI

/// Color of a bingo ball from 1 to 90. Each ten has its own tone (1–10 cobalto, 11–20 turquesa, 21–30 cromo,
/// 31–40 siena, 41–50 bermellón, 51–60 olivo, 61–70 cielo, 71–80 almendro, 81–90 crema), with a matching
/// color for the number printed on it.
public struct DSBallTone: Equatable, Sendable {
    /// Color of the sphere.
    public let fill: Color
    /// Color of the number on the sphere.
    public let numberColor: Color

    /// The tone of the ball with this number. Numbers outside 1–90 are clamped to the nearest ten.
    public init(number: Int) {
        let tones = Self.tones
        let index = min(max((number - 1) / 10, 0), tones.count - 1)
        self = tones[index]
    }

    private init(fill: Color, numberColor: Color) {
        self.fill = fill
        self.numberColor = numberColor
    }

    private static let tones: [DSBallTone] = [
        DSBallTone(fill: DSPalette.cobalto600, numberColor: DSPalette.lienzo50),
        DSBallTone(fill: DSPalette.turquesa600, numberColor: DSPalette.lienzo50),
        DSBallTone(fill: DSPalette.cromo500, numberColor: DSPalette.noche900),
        DSBallTone(fill: DSPalette.siena700, numberColor: DSPalette.lienzo50),
        DSBallTone(fill: DSPalette.bermellon600, numberColor: DSPalette.lienzo50),
        DSBallTone(fill: DSPalette.olivo700, numberColor: DSPalette.lienzo50),
        DSBallTone(fill: DSPalette.cielo400, numberColor: DSPalette.noche900),
        DSBallTone(fill: DSPalette.almendro300, numberColor: DSPalette.noche900),
        DSBallTone(fill: DSPalette.crema, numberColor: DSPalette.noche900)
    ]
}

/// A sphere in a ball tone: the flat tone with a soft light from the top left, as in the drum and the board.
struct DSBallSphere: View {
    let tone: DSBallTone

    var body: some View {
        Circle()
            .fill(tone.fill)
            .overlay {
                Circle().fill(
                    EllipticalGradient(
                        colors: [DSPalette.lienzo50.opacity(0.4), DSPalette.lienzo50.opacity(0)],
                        center: UnitPoint(x: 0.32, y: 0.28),
                        startRadiusFraction: 0,
                        endRadiusFraction: 0.75
                    )
                )
            }
    }
}

#Preview {
    HStack {
        ForEach([5, 15, 25, 35, 45, 55, 65, 75, 85], id: \.self) { number in
            DSBallSphere(tone: DSBallTone(number: number))
                .frame(width: 32, height: 32)
        }
    }
    .padding()
    .background(DSPalette.noche900)
}
