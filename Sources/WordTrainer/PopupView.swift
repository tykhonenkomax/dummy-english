import SwiftUI
import AppKit

// MARK: - Speech bubble shape

/// A rounded card with a soft cloud-like crown of bumps along the top edge
/// and a small tail pointing at the mascot below.
struct CloudBubbleShape: Shape {
    var cornerRadius: CGFloat = 16
    var tailSize: CGFloat = 14
    var tailPosition: CGFloat = 0.24 // 0...1 horizontal fraction, aligned toward mascot's head
    var topBumps: Int = 3
    var bumpDepth: CGFloat = 9

    func path(in rect: CGRect) -> Path {
        let r = cornerRadius
        let body = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height - tailSize)
        var path = Path()

        path.move(to: CGPoint(x: body.minX + r, y: body.minY))

        // Cloud-like bumps along the top edge only.
        let topStart = body.minX + r
        let topEnd = body.maxX - r
        let span = (topEnd - topStart) / CGFloat(topBumps)
        for i in 0..<topBumps {
            let segStart = CGPoint(x: topStart + span * CGFloat(i), y: body.minY)
            let segEnd = CGPoint(x: topStart + span * CGFloat(i + 1), y: body.minY)
            let control = CGPoint(x: (segStart.x + segEnd.x) / 2, y: body.minY - bumpDepth)
            path.addQuadCurve(to: segEnd, control: control)
        }

        path.addArc(center: CGPoint(x: body.maxX - r, y: body.minY + r), radius: r,
                    startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: body.maxX, y: body.maxY - r))
        path.addArc(center: CGPoint(x: body.maxX - r, y: body.maxY - r), radius: r,
                    startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)

        let tailCenterX = body.minX + body.width * tailPosition
        path.addLine(to: CGPoint(x: tailCenterX + tailSize, y: body.maxY))
        path.addLine(to: CGPoint(x: tailCenterX, y: body.maxY + tailSize))
        path.addLine(to: CGPoint(x: tailCenterX - tailSize, y: body.maxY))
        path.addLine(to: CGPoint(x: body.minX + r, y: body.maxY))

        path.addArc(center: CGPoint(x: body.minX + r, y: body.maxY - r), radius: r,
                    startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: body.minX, y: body.minY + r))
        path.addArc(center: CGPoint(x: body.minX + r, y: body.minY + r), radius: r,
                    startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)

        path.closeSubpath()
        return path
    }
}

// MARK: - Mascot

let logoImage: NSImage? = {
    guard let data = Data(base64Encoded: logoPNGBase64) else { return nil }
    return NSImage(data: data)
}()

let barLogoImage: NSImage? = {
    guard let data = Data(base64Encoded: barLogoPNGBase64) else { return nil }
    let image = NSImage(data: data)
    // NSStatusItem sizes its button image from NSImage.size directly, not
    // from SwiftUI frame modifiers — the raw decoded size (600x247) is far
    // too large for the menu bar, so the status item was rendering blank.
    if let native = image?.size, native.width > 0 {
        let targetHeight: CGFloat = 16
        image?.size = NSSize(width: targetHeight * native.width / native.height, height: targetHeight)
    }
    // Template rendering lets macOS auto-adapt the glyph's color to stay
    // visible against any menu bar background — a solid-white image can
    // otherwise vanish against a light bar/wallpaper.
    image?.isTemplate = true
    return image
}()

struct MascotView: View {
    var body: some View {
        Group {
            if let logoImage {
                Image(nsImage: logoImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 56)
                    .shadow(radius: 6, y: 3)
            }
        }
    }
}

// MARK: - Popup view

struct PopupView: View {
    let word: Word

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(word.text)
                        .font(.system(size: 19, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text(word.translation)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                    Text(word.bucket.localizedName())
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 26)
                .frame(width: 250, alignment: .leading)
                .background(
                    CloudBubbleShape()
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                )
                .background(CloudBubbleShape().fill(Color.black.opacity(0.35)))
                .background(
                    CloudBubbleShape()
                        .stroke(Color.white.opacity(0.35), lineWidth: 1.2)
                )
                .shadow(color: .black.opacity(0.35), radius: 14, y: 6)

                sparkleDots
                    .offset(x: 14, y: -16)
            }

            HStack {
                MascotView()
                Spacer()
            }
            .padding(.leading, 20)
            .offset(y: -6)
        }
        .fixedSize()
    }

    private var sparkleDots: some View {
        ZStack {
            Circle().fill(Color.white.opacity(0.9)).frame(width: 7, height: 7).offset(x: -4, y: 18)
            Circle().fill(Color.white.opacity(0.7)).frame(width: 5, height: 5).offset(x: 10, y: 8)
            Circle().fill(Color.white.opacity(0.5)).frame(width: 9, height: 9).offset(x: 4, y: -4)
        }
    }
}

// MARK: - Presenter

enum ScreenCorner: CaseIterable {
    case topLeft, topRight, bottomLeft, bottomRight

    func origin(for size: NSSize, in screenFrame: NSRect, margin: CGFloat = 24) -> NSPoint {
        switch self {
        case .topLeft:
            return NSPoint(x: screenFrame.minX + margin, y: screenFrame.maxY - size.height - margin)
        case .topRight:
            return NSPoint(x: screenFrame.maxX - size.width - margin, y: screenFrame.maxY - size.height - margin)
        case .bottomLeft:
            return NSPoint(x: screenFrame.minX + margin, y: screenFrame.minY + margin)
        case .bottomRight:
            return NSPoint(x: screenFrame.maxX - size.width - margin, y: screenFrame.minY + margin)
        }
    }
}

@MainActor
final class PopupPresenter {
    private var window: NSWindow?
    private var hideWorkItem: DispatchWorkItem?

    func show(_ word: Word, duration: TimeInterval = 8) {
        hideWorkItem?.cancel()
        window?.close()

        let hosting = NSHostingView(rootView: PopupView(word: word))

        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: NSSize(width: 260, height: 150)),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.level = .screenSaver
        panel.hasShadow = false
        panel.contentView = hosting
        panel.ignoresMouseEvents = true
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]

        // Hosting now has a window, so SwiftUI has laid it out — fittingSize is real.
        let size = hosting.fittingSize
        panel.setContentSize(size)

        if let screenFrame = NSScreen.main?.visibleFrame {
            let corner = ScreenCorner.allCases.randomElement() ?? .topRight
            panel.setFrameOrigin(corner.origin(for: size, in: screenFrame))
        }

        panel.orderFrontRegardless()
        window = panel

        let workItem = DispatchWorkItem { [weak self] in
            self?.window?.animator().alphaValue = 0
            self?.window?.close()
        }
        hideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: workItem)
    }
}
