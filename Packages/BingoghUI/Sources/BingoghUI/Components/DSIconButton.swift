import SwiftUI

/// Round button with only an SF Symbol over the night: beside a `DSButton` (for example, "Cantar en voz alta")
/// or in a header (for example, "Repaso" on the caller board). `accessibilityLabel` is required and comes
/// already localised. A disabled button is dimmed.
public struct DSIconButton: View {
    /// `regular` matches the height of `DSButton`; `small` is the minimum touch target, for headers.
    public enum Size: Sendable {
        case regular
        case small
    }

    private let systemImage: String
    private let accessibilityLabel: String
    private let size: Size
    private let action: @MainActor () -> Void

    @Environment(\.isEnabled) private var isEnabled

    public init(
        systemImage: String,
        accessibilityLabel: String,
        size: Size = .regular,
        action: @escaping @MainActor () -> Void
    ) {
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
        self.size = size
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(size == .regular ? DSTypeScale.titulo3 : DSTypeScale.headline)
                .foregroundStyle(DSColor.textPrimary)
                .frame(width: diameter, height: diameter)
                .background(Circle().fill(DSColor.textPrimary.opacity(0.14)))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.45)
        .accessibilityLabel(accessibilityLabel)
    }

    private var diameter: CGFloat {
        size == .regular ? DSSpacing.tapMin + DSSpacing.small : DSSpacing.tapMin
    }
}

#Preview {
    DSIconButton(systemImage: "mic", accessibilityLabel: "Cantar en voz alta") {}
        .padding()
        .background(DSPalette.noche900)
        .environment(\.colorScheme, .dark)
}
