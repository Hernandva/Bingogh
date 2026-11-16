import SwiftUI

/// the caller board: the 90 numbers of the game, with the drawn ones as balls in their tone and the last one
/// drawn ringed. Its header shows a title and a counter, both already localised.
public struct DSCallerBoard: View {
    /// How the 90 numbers are laid out.
    public enum Layout: Sendable {
        /// 9 columns of 10 rows, one column per ten (1–10, 11–20…). For iPhone.
        case portrait
        /// 10 columns of 9 rows, one row per ten. For iPad and the TV.
        case landscape
    }

    /// Scale of the board: `compact` on iPhone, `regular` on iPad and `television` on an external display.
    public enum Size: Sendable {
        case compact
        case regular
        case television
    }

    private let title: String
    private let counter: String
    private let drawnNumbers: Set<Int>
    private let lastNumber: Int?
    private let layout: Layout
    private let metrics: Metrics

    public init(
        title: String,
        counter: String,
        drawnNumbers: Set<Int>,
        lastNumber: Int?,
        layout: Layout,
        size: Size
    ) {
        self.title = title
        self.counter = counter
        self.drawnNumbers = drawnNumbers
        self.lastNumber = lastNumber
        self.layout = layout
        self.metrics = Metrics(size: size)
    }

    public var body: some View {
        VStack(spacing: metrics.spacing) {
            header
            grid
        }
        .padding(metrics.padding)
        .background {
            RoundedRectangle(cornerRadius: metrics.radius)
                .fill(DSPalette.crema.opacity(0.05))
                .overlay {
                    RoundedRectangle(cornerRadius: metrics.radius)
                        .strokeBorder(DSPalette.crema.opacity(0.08), lineWidth: 1)
                }
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Text(counter)
                .fontDesign(.rounded)
                .monospacedDigit()
                .foregroundStyle(DSPalette.crema.opacity(0.7))
        }
        .font(metrics.headerFont)
        .foregroundStyle(DSPalette.crema)
        .padding(.horizontal, DSSpacing.xSmall)
    }

    private var grid: some View {
        VStack(spacing: metrics.gap) {
            ForEach(0..<rowCount, id: \.self) { row in
                HStack(spacing: metrics.gap) {
                    ForEach(0..<columnCount, id: \.self) { column in
                        cell(number(row: row, column: column))
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var rowCount: Int { layout == .portrait ? 10 : 9 }
    private var columnCount: Int { layout == .portrait ? 9 : 10 }

    private func number(row: Int, column: Int) -> Int {
        layout == .portrait ? column * 10 + row + 1 : row * 10 + column + 1
    }

    private func cell(_ number: Int) -> some View {
        DSBoardCell(number: number, isDrawn: drawnNumbers.contains(number), isLast: number == lastNumber)
            .font(.system(size: metrics.numberSize, weight: .heavy, design: .rounded))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// One number of the caller board: plain text until it is drawn, then a ball in its tone.
private struct DSBoardCell: View {
    let number: Int
    let isDrawn: Bool
    let isLast: Bool

    var body: some View {
        Group {
            if isDrawn {
                drawn
            } else {
                Text(number, format: .number)
                    .foregroundStyle(DSPalette.crema.opacity(0.62))
            }
        }
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(number, format: .number))
        .accessibilityAddTraits(isDrawn ? .isSelected : [])
    }

    private var drawn: some View {
        let tone = DSBallTone(number: number)
        return DSBallSphere(tone: tone)
            .overlay {
                Text(number, format: .number)
                    .foregroundStyle(tone.numberColor)
                    .padding(DSSpacing.xSmall / 2)
            }
            .overlay {
                if isLast {
                    Circle().strokeBorder(DSPalette.noche900, lineWidth: 3).padding(-3)
                    Circle().strokeBorder(DSPalette.lienzo50, lineWidth: 2).padding(-5)
                }
            }
            .aspectRatio(1, contentMode: .fit)
    }
}

/// Sizes of the board for each scale, from the iPhone, iPad and TV designs.
private struct Metrics {
    let padding: CGFloat
    let spacing: CGFloat
    let gap: CGFloat
    let radius: CGFloat
    let numberSize: CGFloat
    let headerFont: Font

    init(size: DSCallerBoard.Size) {
        switch size {
        case .compact:
            padding = DSSpacing.espacioS
            spacing = DSSpacing.espacioS
            gap = DSSpacing.xSmall
            radius = DSRadius.radioCarton
            numberSize = 14
            headerFont = DSTypeScale.headline
        case .regular:
            padding = DSSpacing.espacioL
            spacing = DSSpacing.espacioS
            gap = DSSpacing.small
            radius = DSRadius.radioCarton
            numberSize = 22
            headerFont = DSTypeScale.titulo2
        case .television:
            padding = DSSpacing.xLarge
            spacing = DSSpacing.espacioL
            gap = DSSpacing.espacioS
            radius = DSRadius.radioHoja
            numberSize = 36
            headerFont = DSTypeScale.tvCuerpo.weight(.semibold)
        }
    }
}

#Preview {
    DSCallerBoard(
        title: "Tablero maestro",
        counter: "6 de 90",
        drawnNumbers: [3, 22, 41, 47, 63, 84],
        lastNumber: 47,
        layout: .portrait,
        size: .compact
    )
    .padding()
    .frame(height: 700)
    .background(DSPalette.noche900)
}
