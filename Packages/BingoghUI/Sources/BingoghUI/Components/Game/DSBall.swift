import SwiftUI

/// The ball that has just come out of the drum: a sphere in the tone of its ten, with a cream disc in the
/// middle that shows the number. 180 pt on iPhone, 260 pt on iPad and 520 pt on a TV.
public struct DSBall: View {
    private let number: Int
    private let diameter: CGFloat

    public init(number: Int, diameter: CGFloat) {
        self.number = number
        self.diameter = diameter
    }

    public var body: some View {
        DSBallSphere(tone: DSBallTone(number: number))
            .overlay {
                Circle()
                    .fill(DSPalette.lienzo50)
                    .overlay {
                        Circle().strokeBorder(DSPalette.noche900.opacity(0.12), lineWidth: diameter * 0.015)
                    }
                    .padding(diameter * 0.18)
            }
            .overlay {
                Text(number, format: .number)
                    .font(.system(size: diameter * 0.3, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(DSPalette.tinta900)
            }
            .frame(width: diameter, height: diameter)
            .shadow(color: DSPalette.noche900.opacity(0.55), radius: diameter * 0.08, y: diameter * 0.08)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(number, format: .number))
    }
}

#Preview {
    HStack(spacing: DSSpacing.large) {
        DSBall(number: 7, diameter: 180)
        DSBall(number: 47, diameter: 180)
        DSBall(number: 84, diameter: 180)
    }
    .padding()
    .background(DSPalette.noche900)
}
