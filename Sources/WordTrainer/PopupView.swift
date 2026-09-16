import SwiftUI
import AppKit

// MARK: - Speech bubble shape

struct SpeechBubbleShape: Shape {
    var cornerRadius: CGFloat = 18
    var tailSize: CGFloat = 14
    var tailPosition: CGFloat = 0.28 // 0...1 horizontal fraction, aligned toward mascot's head

    func path(in rect: CGRect) -> Path {
        let bubbleRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height - tailSize)
        var path = Path(roundedRect: bubbleRect, cornerRadius: cornerRadius)
        let tailX = bubbleRect.minX + bubbleRect.width * tailPosition
        path.move(to: CGPoint(x: tailX - tailSize * 0.7, y: bubbleRect.maxY - 1))
        path.addLine(to: CGPoint(x: tailX, y: bubbleRect.maxY + tailSize))
        path.addLine(to: CGPoint(x: tailX + tailSize * 0.7, y: bubbleRect.maxY - 1))
        path.closeSubpath()
        return path
    }
}

// MARK: - Mascot

let logoImage: NSImage? = {
    guard let url = Bundle.module.url(forResource: "logo", withExtension: "png") else { return nil }
    let image = NSImage(contentsOf: url)
    // @2x (36x36 px) square asset for a menu bar glyph — pure white, not a template.
    image?.size = NSSize(width: 22, height: 22)
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
            VStack(alignment: .leading, spacing: 6) {
                Text(word.text)
                    .font(.system(size: 19, weight: .bold))
                Text(word.translation)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                Text(word.bucket.rawValue)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 20)
            .frame(width: 240, alignment: .leading)
            .background(
                SpeechBubbleShape()
                    .fill(.ultraThinMaterial)
            )
            .background(
                SpeechBubbleShape()
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
            .shadow(radius: 10, y: 4)

            HStack {
                MascotView()
                Spacer()
            }
            .padding(.leading, 24)
            .offset(y: -4)
        }
        .fixedSize()
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
