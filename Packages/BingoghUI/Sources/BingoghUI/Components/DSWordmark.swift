import SwiftUI

/// The app's name set as a wordmark: serif, bold, centred. 64 points on iPhone and 120 on iPad
/// (regular width), scaled with Dynamic Type. `.localized(_:)` localises the text.
public struct DSWordmark: View, DSLocalizableText {
    public var text: String

    @Environment(\.horizontalSizeClass) private var sizeClass
    @ScaledMetric(relativeTo: .largeTitle) private var compactSize: CGFloat = 64
    @ScaledMetric(relativeTo: .largeTitle) private var regularSize: CGFloat = 120

    public init(_ text: String = "") {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.system(size: sizeClass == .regular ? regularSize : compactSize, weight: .bold, design: .serif))
            .tracking(-0.02 * (sizeClass == .regular ? regularSize : compactSize))
            .foregroundStyle(DSColor.textPrimary)
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity)
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    DSWordmark("Bingogh")
        .padding()
        .background(DSPalette.noche900)
        .environment(\.colorScheme, .dark)
}
