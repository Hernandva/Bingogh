import SwiftUI

/// Round button with only an SF Symbol, beside a `DSButton` over the night (for example, "Cantar en voz alta").
/// Its size matches the height of `DSButton`. `accessibilityLabel` is required and comes already localised.
public struct DSIconButton: View {
    private let systemImage: String
    private let accessibilityLabel: String
    private let action: @MainActor () -> Void

    public init(systemImage: String, accessibilityLabel: String, action: @escaping @MainActor () -> Void) {
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(DSTypeScale.titulo3)
                .foregroundStyle(DSColor.textPrimary)
                .frame(width: DSSpacing.tapMin + DSSpacing.small, height: DSSpacing.tapMin + DSSpacing.small)
                .background(Circle().fill(DSColor.textPrimary.opacity(0.14)))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    DSIconButton(systemImage: "mic", accessibilityLabel: "Cantar en voz alta") {}
        .padding()
        .background(DSPalette.noche900)
        .environment(\.colorScheme, .dark)
}
