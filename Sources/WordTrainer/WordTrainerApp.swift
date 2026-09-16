import SwiftUI
import AppKit
import Combine

@main
struct WordTrainerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            Button(L(.adminMenuItem)) {
                appDelegate.showAdmin()
            }
            Button(L(.showWordNow)) {
                appDelegate.showRandomWordNow()
            }
            Divider()
            Button(L(.quitMenuItem)) {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            if let barLogoImage {
                Image(nsImage: barLogoImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 16)
            } else {
                Text("Ghostty English")
            }
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let store = Store()
    private let popupPresenter = PopupPresenter()
    private var adminWindow: NSWindow?
    private var cancellable: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        cancellable = store.$wordToShow.sink { [weak self] word in
            guard let word else { return }
            self?.popupPresenter.show(word)
        }
    }

    func showAdmin() {
        if adminWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 960, height: 520),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.contentView = NSHostingView(rootView: AdminView(store: store))
            window.isReleasedWhenClosed = false
            window.center()
            adminWindow = window
        }
        adminWindow?.title = "Ghostty English \(L(.adminWindowTitleSuffix))"
        NSApp.activate(ignoringOtherApps: true)
        adminWindow?.makeKeyAndOrderFront(nil)
    }

    func showRandomWordNow() {
        let all = store.words
        guard let word = all.randomElement() else { return }
        popupPresenter.show(word)
    }
}
