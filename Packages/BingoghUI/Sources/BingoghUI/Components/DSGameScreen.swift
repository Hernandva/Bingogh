import SwiftUI

/// Full-screen container of the game (iPhone, iPad and the TV): the night gradient, from noche-900 to noche-800,
/// with the dark appearance forced. Unlike `DSNightScreen` it adds no margins or column, because each device
/// lays the drum and the board out its own way.
public struct DSGameScreen<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                LinearGradient(colors: [DSPalette.noche900, DSPalette.noche800], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }
            .environment(\.colorScheme, .dark)
            .gameNavigationBar()
    }
}

private extension View {
    /// Transparent navigation bar with light content, so the back button reads on the gradient.
    @ViewBuilder
    func gameNavigationBar() -> some View {
        #if os(iOS)
        toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}

#Preview {
    DSGameScreen {
        DSDrum(radius: 150)
    }
}
