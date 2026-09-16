import SwiftUI
import AppKit
import Combine

@main
struct WordTrainerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("Word Trainer", systemImage: "textformat.abc") {
            Button("Адмінка…") {
                appDelegate.showAdmin()
            }
            Button("Показати слово зараз") {
                appDelegate.showRandomWordNow()
            }
            Divider()
            Button("Вийти") {
                NSApplication.shared.terminate(nil)
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
                contentRect: NSRect(x: 0, y: 0, width: 780, height: 480),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.title = "Word Trainer — Адмінка"
            window.contentView = NSHostingView(rootView: AdminView(store: store))
            window.isReleasedWhenClosed = false
            window.center()
            adminWindow = window
        }
        NSApp.activate(ignoringOtherApps: true)
        adminWindow?.makeKeyAndOrderFront(nil)
    }

    func showRandomWordNow() {
        let all = store.words
        guard let word = all.randomElement() else { return }
        popupPresenter.show(word)
    }
}
