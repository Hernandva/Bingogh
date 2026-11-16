import SwiftUI

/// Full-screen container over the night sky, for screens that do not scroll (Inicio, sorteo).
/// It always uses the dark appearance, so the semantic colors resolve to their night values (crema text,
/// cobalto-500 accent). The content is laid out in a column with the screen margins, between the safe areas.
public struct DSNightScreen<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: DSSpacing.medium) {
            content
        }
        .padding(.horizontal, DSSpacing.medium)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { DSNightSky().ignoresSafeArea() }
        .environment(\.colorScheme, .dark)
        .lightNavigationBar()
    }
}

private extension View {
    /// Transparent navigation bar with light content, so the status bar reads on the night sky.
    @ViewBuilder
    func lightNavigationBar() -> some View {
        #if os(iOS)
        toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        #else
        self
        #endif
    }
}

#Preview {
    DSNightScreen {
        Spacer()
        DSWordmark("Bingogh")
        Spacer()
        DSButton("Partida nueva", systemImage: "plus") {}
    }
}
