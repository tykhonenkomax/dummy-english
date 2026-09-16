import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct AdminView: View {
    @ObservedObject var store: Store

    @State private var newWord = ""
    @State private var newTranslation = ""

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            VStack(spacing: 0) {
                toolbar
                addForm
                Divider()
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Bucket.allCases) { bucket in
                        BucketColumn(store: store, bucket: bucket)
                        if bucket != Bucket.allCases.last {
                            Divider()
                        }
                    }
                }
            }
        }
        .frame(minWidth: 900, minHeight: 460)
    }

    private var sidebar: some View {
        VStack(spacing: 14) {
            Spacer()
            Text("Dummy English")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            if let benderImage {
                Image(nsImage: benderImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120)
                    .shadow(radius: 6, y: 3)
            }
            Spacer()
        }
        .frame(width: 160)
        .frame(maxHeight: .infinity)
        .background(Color.gray.opacity(0.18))
    }

    private var toolbar: some View {
        HStack {
            Text("База зберігається локально — розкажу нижче.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button("Імпорт бази…", action: importBackup)
            Button("Експорт бази…", action: exportBackup)
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
    }

    private func dropboxIfAvailable() -> URL? {
        let dropbox = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Dropbox")
        return FileManager.default.fileExists(atPath: dropbox.path) ? dropbox : nil
    }

    private func exportBackup() {
        let panel = NSSavePanel()
        panel.title = "Експорт бази слів"
        panel.nameFieldStringValue = "wordtrainer-backup.json"
        panel.allowedContentTypes = [.json]
        panel.directoryURL = dropboxIfAvailable()
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try store.exportBackup(to: url)
        } catch {
            presentAlert("Не вдалося зберегти файл: \(error.localizedDescription)")
        }
    }

    private func importBackup() {
        let panel = NSOpenPanel()
        panel.title = "Імпорт бази слів"
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.directoryURL = dropboxIfAvailable()
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try store.importBackup(from: url)
        } catch {
            presentAlert("Не вдалося завантажити файл: \(error.localizedDescription)")
        }
    }

    private func presentAlert(_ message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.runModal()
    }

    private var addForm: some View {
        HStack {
            TextField("Слово (англ.)", text: $newWord)
                .textFieldStyle(.roundedBorder)
            TextField("Переклад", text: $newTranslation)
                .textFieldStyle(.roundedBorder)
            Button("Додати") {
                store.addWord(text: newWord, translation: newTranslation)
                newWord = ""
                newTranslation = ""
            }
            .disabled(newWord.trimmingCharacters(in: .whitespaces).isEmpty
                      || newTranslation.trimmingCharacters(in: .whitespaces).isEmpty)
            .keyboardShortcut(.return, modifiers: [])
        }
        .padding(12)
    }
}

private struct BucketColumn: View {
    @ObservedObject var store: Store
    let bucket: Bucket

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(bucket.rawValue)
                .font(.headline)
                .padding(.horizontal, 12)
                .padding(.top, 10)

            IntervalField(store: store, bucket: bucket)
                .padding(.horizontal, 12)

            Divider()

            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(store.words(in: bucket)) { word in
                        WordRow(store: store, word: word)
                    }
                }
                .padding(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

private struct IntervalField: View {
    @ObservedObject var store: Store
    let bucket: Bucket
    @State private var text: String = ""

    var body: some View {
        HStack(spacing: 6) {
            Text("Кожні")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("", text: $text)
                .textFieldStyle(.roundedBorder)
                .frame(width: 50)
                .onSubmit(commit)
            Text("хв")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .onAppear {
            text = formatted(store.settings.interval(for: bucket))
        }
        .onChange(of: store.settings.interval(for: bucket)) { newValue in
            text = formatted(newValue)
        }
        .onSubmit(commit)
    }

    private func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(value)
    }

    private func commit() {
        guard let value = Double(text.replacingOccurrences(of: ",", with: ".")), value > 0 else {
            text = formatted(store.settings.interval(for: bucket))
            return
        }
        store.setInterval(value, for: bucket)
    }
}

private struct WordRow: View {
    @ObservedObject var store: Store
    let word: Word

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(word.text).font(.system(size: 13, weight: .medium))
                Text(word.translation).font(.system(size: 11)).foregroundStyle(.secondary)
            }
            Spacer()
            Menu {
                ForEach(Bucket.allCases.filter { $0 != word.bucket }) { target in
                    Button("→ \(target.rawValue)") {
                        store.move(word, to: target)
                    }
                }
                Divider()
                Button("Видалити", role: .destructive) {
                    store.deleteWord(word)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .menuStyle(.borderlessButton)
            .frame(width: 20)
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}
