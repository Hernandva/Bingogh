import SwiftUI

/// Capsule segmented control for screens over the night (Bombo / Tablero). Each option's title comes
/// already localised. The selected segment carries the selected trait for VoiceOver.
public struct DSSegmentedControl<Value: Hashable>: View {
    /// One segment: the value it selects and its localised title.
    public struct Option: Identifiable {
        public let value: Value
        public let title: String
        public var id: Value { value }

        public init(_ value: Value, title: String) {
            self.value = value
            self.title = title
        }
    }

    @Binding private var selection: Value
    private let options: [Option]

    public init(selection: Binding<Value>, options: [Option]) {
        _selection = selection
        self.options = options
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(options) { option in
                segment(option)
            }
        }
        .padding(2)
        .frame(height: DSSpacing.xLarge + DSSpacing.xSmall)
        .background(Capsule().fill(DSPalette.crema.opacity(0.12)))
        .animation(.snappy, value: selection)
    }

    private func segment(_ option: Option) -> some View {
        let isSelected = option.value == selection
        return Button {
            selection = option.value
        } label: {
            Text(option.title)
                .font(DSTypeScale.subheadline.weight(.semibold))
                .foregroundStyle(DSPalette.crema.opacity(isSelected ? 1 : 0.82))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    if isSelected {
                        Capsule().fill(DSPalette.crema.opacity(0.26))
                    }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var selection = 0
    DSSegmentedControl(
        selection: $selection,
        options: [.init(0, title: "Bombo"), .init(1, title: "Tablero")]
    )
    .padding()
    .background(DSPalette.noche900)
}
