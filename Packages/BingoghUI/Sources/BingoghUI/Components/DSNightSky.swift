import SwiftUI

/// Night sky of the design system (`gradiente-noche-luna`): the night gradient, the moon with its halo,
/// the ring texture, two swirls and three stars. It is drawn in a 390 × 844 reference frame and scales to any size.
public struct DSNightSky: View {
    public init() {}

    public var body: some View {
        Canvas { context, size in
            let sky = NightSkyLayout(size: size)
            sky.drawGradient(in: &context)
            sky.drawTexture(in: &context)
            sky.drawSwirls(in: &context)
            sky.drawMoonAndStars(in: &context)
        }
        .accessibilityHidden(true)
    }
}

/// Geometry of the night sky for one canvas size.
private struct NightSkyLayout {
    /// A star or the moon: centre as a fraction of the canvas, radius and halo rings in reference points.
    struct Light {
        let unitCenter: CGPoint
        let radius: CGFloat
        let rings: [(radius: CGFloat, opacity: Double)]
    }

    /// A swirl: centre as a fraction of the canvas, turns, rotation, scale, colors and opacity.
    struct Swirl {
        let unitCenter: CGPoint
        let turns: Int
        let rotation: Angle
        let scale: CGFloat
        let colors: [Color]
        let opacity: Double
    }

    static let referenceWidth: CGFloat = 390
    static let moon = Light(
        unitCenter: CGPoint(x: 0.826, y: 0.14),
        radius: 26,
        rings: [(42, 0.45), (60, 0.25)]
    )
    static let stars = [
        Light(unitCenter: CGPoint(x: 0.154, y: 0.178), radius: 9, rings: [(19, 0.4)]),
        Light(unitCenter: CGPoint(x: 0.246, y: 0.557), radius: 7, rings: [(15, 0.4)]),
        Light(unitCenter: CGPoint(x: 0.846, y: 0.616), radius: 8, rings: [(17, 0.4)])
    ]
    static let swirls = [
        Swirl(
            unitCenter: CGPoint(x: 0.436, y: 0.355), turns: 12, rotation: .zero, scale: 1,
            colors: [DSPalette.cromo300, DSPalette.cielo400], opacity: 0.9
        ),
        Swirl(
            unitCenter: CGPoint(x: 0.641, y: 0.427), turns: 8, rotation: .degrees(40), scale: 0.8,
            colors: [DSPalette.cielo300, DSPalette.noche700], opacity: 0.85
        )
    ]

    let size: CGSize
    /// Scale from the 390-point reference frame, based on the shorter side so landscape does not blow it up.
    var scale: CGFloat { min(size.width, size.height) / Self.referenceWidth }

    func point(_ unit: CGPoint) -> CGPoint {
        CGPoint(x: unit.x * size.width, y: unit.y * size.height)
    }

    func drawGradient(in context: inout GraphicsContext) {
        let rect = Path(CGRect(origin: .zero, size: size))
        context.fill(rect, with: .linearGradient(
            Gradient(stops: [
                .init(color: DSPalette.noche950, location: 0),
                .init(color: DSPalette.noche800, location: 0.58),
                .init(color: DSPalette.noche700, location: 1)
            ]),
            startPoint: CGPoint(x: size.width * 0.41, y: 0),
            endPoint: CGPoint(x: size.width * 0.59, y: size.height)
        ))
        let glowCenter = point(Self.moon.unitCenter)
        let reach = hypot(max(glowCenter.x, size.width - glowCenter.x), max(glowCenter.y, size.height - glowCenter.y))
        context.fill(rect, with: .radialGradient(
            Gradient(stops: [
                .init(color: DSPalette.cromo300, location: 0),
                .init(color: DSPalette.cromo400, location: 0.125),
                .init(color: DSPalette.cromo400.opacity(0), location: 1)
            ]),
            center: glowCenter, startRadius: 0, endRadius: reach * 0.24
        ))
    }

    /// Concentric rings, 2 points wide every 15 points, centred at 70 % × 30 %.
    func drawTexture(in context: inout GraphicsContext) {
        let center = CGPoint(x: size.width * 0.7, y: size.height * 0.3)
        let reach = hypot(size.width, size.height)
        var rings = Path()
        for radius in stride(from: CGFloat(1), through: reach, by: 15) {
            rings.addPath(circle(center: center, radius: radius))
        }
        context.stroke(rings, with: .color(DSPalette.cromo300.opacity(0.06)), lineWidth: 2)
    }

    func drawSwirls(in context: inout GraphicsContext) {
        for swirl in Self.swirls {
            let origin = point(swirl.unitCenter)
            let path = Self.spiral(turns: swirl.turns).applying(
                CGAffineTransform(scaleX: swirl.scale * scale, y: swirl.scale * scale)
                    .concatenating(CGAffineTransform(rotationAngle: swirl.rotation.radians))
                    .concatenating(CGAffineTransform(translationX: origin.x, y: origin.y))
            )
            let bounds = path.boundingRect
            context.drawLayer { layer in
                layer.opacity = swirl.opacity
                layer.stroke(
                    path,
                    with: .linearGradient(
                        Gradient(colors: swirl.colors),
                        startPoint: CGPoint(x: bounds.minX, y: bounds.minY),
                        endPoint: CGPoint(x: bounds.maxX, y: bounds.maxY)
                    ),
                    style: StrokeStyle(lineWidth: 6 / scale.squareRoot(), lineCap: .round)
                )
            }
        }
    }

    func drawMoonAndStars(in context: inout GraphicsContext) {
        for light in [Self.moon] + Self.stars {
            let center = point(light.unitCenter)
            context.fill(circle(center: center, radius: light.radius * scale), with: .color(DSPalette.cromo300))
            for ring in light.rings {
                context.stroke(
                    circle(center: center, radius: ring.radius * scale),
                    with: .color(DSPalette.cromo400.opacity(ring.opacity)),
                    lineWidth: 3
                )
            }
        }
    }

    func circle(center: CGPoint, radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    }

    /// Spiral of half circles that grow 10 points per turn, alternating sides, starting at the origin.
    static func spiral(turns: Int) -> Path {
        var path = Path()
        var current = CGPoint.zero
        path.move(to: current)
        for turn in 1...turns {
            let radius = CGFloat(turn) * 10
            let direction: CGFloat = turn.isMultiple(of: 2) ? -1 : 1
            let center = CGPoint(x: current.x + radius * direction, y: current.y)
            path.addRelativeArc(
                center: center,
                radius: radius,
                startAngle: .degrees(direction > 0 ? 180 : 0),
                delta: .degrees(180)
            )
            current = CGPoint(x: center.x + radius * direction, y: center.y)
        }
        return path
    }
}

#Preview {
    DSNightSky().ignoresSafeArea()
}
