import SwiftUI

/// Full-width capsule button with the design-system styles applied and an optional SF Symbol before the text.
public struct DSButton: View, DSLocalizableText {
    public enum Style: Sendable {
        case primary
        case secondary
        case destructive
        /// Frosted capsule for screens over the night sky: material, a light fill and a hairline border.
        case translucent
    }

    public var text: String
    private let systemImage: String?
    private let style: Style
    private let action: @MainActor () -> Void

    public init(
        _ text: String = "",
        systemImage: String? = nil,
        style: Style = .primary,
        action: @escaping @MainActor () -> Void
    ) {
        self.text = text
        self.systemImage = systemImage
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            DSButtonLabel(text: text, systemImage: systemImage)
        }
        .buttonStyle(DSButtonStyle(style: style))
    }
}

/// Content of `DSButton` and `DSNavigationButton`: the optional SF Symbol and the text, full width.
struct DSButtonLabel: View {
    let text: String
    let systemImage: String?

    var body: some View {
        HStack(spacing: DSSpacing.small) {
            if let systemImage {
                Image(systemName: systemImage)
                    .fontWeight(.bold)
                    .accessibilityHidden(true)
            }
            Text(text)
        }
        .font(DSFont.bodyStrong)
        .frame(maxWidth: .infinity, minHeight: DSSpacing.tapMin + DSSpacing.small)
        .padding(.horizontal, DSSpacing.medium)
    }
}

/// Capsule look of `DSButton` and `DSNavigationButton` for each style.
struct DSButtonStyle: ButtonStyle {
    let style: DSButton.Style

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground)
            .background { background }
            .opacity(configuration.isPressed ? 0.8 : 1)
            .contentShape(Capsule())
    }

    private var foreground: Color {
        switch style {
        case .primary: DSColor.onAccent
        case .secondary: DSColor.accent
        case .destructive: DSColor.onDestructive
        case .translucent: DSColor.textPrimary
        }
    }

    @ViewBuilder private var background: some View {
        switch style {
        case .primary: Capsule().fill(DSColor.accent)
        case .secondary: Capsule().fill(DSColor.fillSecondary)
        case .destructive: Capsule().fill(DSColor.destructive)
        case .translucent:
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay { Capsule().fill(DSColor.textPrimary.opacity(0.16)) }
                .overlay { Capsule().strokeBorder(DSColor.textPrimary.opacity(0.2), lineWidth: 1) }
        }
    }
}

#Preview {
    VStack {
        DSButton("Primary", systemImage: "plus") {}
        DSButton("Secondary", style: .secondary) {}
        DSButton("Delete", style: .destructive) {}
        DSButton("Translucent", systemImage: "play.fill", style: .translucent) {}
    }
    .padding()
    .background(DSPalette.noche800)
}
