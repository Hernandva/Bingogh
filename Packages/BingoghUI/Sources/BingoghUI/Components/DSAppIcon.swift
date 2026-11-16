import SwiftUI

/// The app icon: a cromo ball centred on the plain night gradient (noche-900 to noche-800), square and without
/// rounded corners (the system masks it). `side` is the length of the side in points; the app's
/// `AppIcon` is rendered from it at 1024 points with `scripts/render_app_icon.sh`.
public struct DSAppIcon: View {
    /// Number printed on the ball of the icon.
    public static let number = 27

    private let side: CGFloat

    public init(side: CGFloat = 1024) {
        self.side = side
    }

    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [DSPalette.noche900, DSPalette.noche800],
                startPoint: .top,
                endPoint: .bottom
            )
            DSBall(number: Self.number, diameter: side * 0.68)
        }
        .frame(width: side, height: side)
        .clipped()
        .environment(\.colorScheme, .dark)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Bingogh"))
    }
}

#Preview {
    HStack(spacing: DSSpacing.large) {
        DSAppIcon(side: 180)
            .clipShape(RoundedRectangle(cornerRadius: 180 * 0.225, style: .continuous))
        DSAppIcon(side: 60)
            .clipShape(RoundedRectangle(cornerRadius: 60 * 0.225, style: .continuous))
    }
    .padding()
}
