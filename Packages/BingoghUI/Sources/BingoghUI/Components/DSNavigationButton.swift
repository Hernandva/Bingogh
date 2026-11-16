import SwiftUI

/// A `DSButton` that pushes a screen: a `NavigationLink(value:)` with the capsule look of `DSButton`.
/// Use it for buttons that open another feature through a coordinator route.
public struct DSNavigationButton<Value: Hashable>: View, DSLocalizableText {
    public var text: String
    private let value: Value
    private let systemImage: String?
    private let style: DSButton.Style

    public init(
        _ text: String = "",
        value: Value,
        systemImage: String? = nil,
        style: DSButton.Style = .primary
    ) {
        self.text = text
        self.value = value
        self.systemImage = systemImage
        self.style = style
    }

    public var body: some View {
        NavigationLink(value: value) {
            DSButtonLabel(text: text, systemImage: systemImage)
        }
        .buttonStyle(DSButtonStyle(style: style))
    }
}

#Preview {
    NavigationStack {
        DSButtonGroup {
            DSNavigationButton("Partida nueva", value: 1, systemImage: "plus")
            DSNavigationButton("Continuar partida", value: 2, systemImage: "play.fill", style: .translucent)
        }
        .padding()
        .navigationDestination(for: Int.self) { Text("\($0)") }
    }
}
