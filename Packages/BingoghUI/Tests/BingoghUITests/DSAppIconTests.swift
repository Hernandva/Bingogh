@testable import BingoghUI
import CoreGraphics
import Foundation
import ImageIO
import SwiftUI
import Testing
import UniformTypeIdentifiers

/// Renders `DSAppIcon` at 1024 × 1024. When `BINGOGH_APP_ICON_OUTPUT` holds a file path, it also writes
/// the icon there as an opaque PNG (no alpha channel), which is what `scripts/render_app_icon.sh` uses.
@MainActor
struct DSAppIconTests {
    private static let pixels = 1024

    @Test func rendersAnOpaqueSquareIcon() throws {
        let image = try #require(Self.renderOpaque())
        #expect(image.width == Self.pixels)
        #expect(image.height == Self.pixels)
        #expect(image.alphaInfo == .noneSkipLast)

        if let output = ProcessInfo.processInfo.environment["BINGOGH_APP_ICON_OUTPUT"] {
            try Self.writePNG(image, to: URL(fileURLWithPath: output))
        }
    }

    private static func renderOpaque() -> CGImage? {
        let renderer = ImageRenderer(content: DSAppIcon(side: CGFloat(pixels)))
        renderer.scale = 1
        guard let rendered = renderer.cgImage,
              let context = CGContext(
                data: nil,
                width: pixels,
                height: pixels,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
              ) else {
            return nil
        }
        context.draw(rendered, in: CGRect(x: 0, y: 0, width: pixels, height: pixels))
        return context.makeImage()
    }

    private static func writePNG(_ image: CGImage, to url: URL) throws {
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL, UTType.png.identifier as CFString, 1, nil
        ) else {
            throw CocoaError(.fileWriteUnknown)
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw CocoaError(.fileWriteUnknown)
        }
    }
}
