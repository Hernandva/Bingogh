import SwiftUI

/// Column of stacked `DSButton`s. Full width on iPhone; on iPad it stops at 380 points, centred.
public struct DSButtonGroup<Content: View>: View {
    private static var maxWidth: CGFloat { 380 }

    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: DSSpacing.espacioS) {
            content
        }
        .frame(maxWidth: Self.maxWidth)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    DSButtonGroup {
        DSButton("Partida nueva", systemImage: "plus") {}
        DSButton("Continuar partida", systemImage: "play.fill", style: .secondary) {}
    }
    .padding()
}
