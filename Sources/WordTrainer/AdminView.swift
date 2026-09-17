import SwiftUI
import AppKit
import UniformTypeIdentifiers

private enum Palette {
    static let bg = Color.black
    static let card = Color.white.opacity(0.05)
    static let border = Color.white.opacity(0.16)
    static let muted = Color.white.opacity(0.55)
    static let accent = Color(red: 0.35, green: 0.51, blue: 0.98) // matches app icon blue

    static func tint(for bucket: Bucket) -> Color {
        switch bucket {
        case .bad: return Color(red: 0.95, green: 0.42, blue: 0.42)
        case .medium: return Color(red: 0.96, green: 0.72, blue: 0.24)
        case .good: return Color(red: 0.30, green: 0.78, blue: 0.47)
        }
    }

    static func icon(for bucket: Bucket) -> String {
        switch bucket {
        case .bad: return "questionmark.circle.fill"
        case .medium: return "book.fill"
        case .good: return "star.fill"
        }
    }
}

struct AdminView: View {
    @ObservedObject var store: Store
    @ObservedObject private var loc = Loc.shared

    @State private var newWord = ""
    @State private var newTranslation = ""

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            VStack(spacing: 0) {
                toolbar
                addForm
                HStack(alignment: .top, spacing: 12) {
                    ForEach(Bucket.allCases) { bucket in
                        BucketColumn(store: store, bucket: bucket)
                    }
                }
                .padding(14)
            }
            .background(Palette.bg)
        }
        .frame(minWidth: 960, minHeight: 520)
        .background(Palette.bg)
        .preferredColorScheme(.dark)
    }

    private var sidebar: some View {
        VStack(spacing: 14) {
            Spacer()
            if let logoImage {
                Image(nsImage: logoImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 92)
                    .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
            }
            Text("Ghostty English")
                .font(.system(size: 19, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            Text("\(store.words.count) \(loc.t(.wordsCountSuffix))")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Palette.muted)

            Divider().background(Palette.border).padding(.horizontal, 20)

            languagePicker

            Spacer()
        }
        .frame(width: 170)
        .frame(maxHeight: .infinity)
        .background(Color.white.opacity(0.03))
        .overlay(Rectangle().frame(width: 1).foregroundStyle(Palette.border), alignment: .trailing)
    }

    private var languagePicker: some View {
        VStack(spacing: 8) {
            Text(loc.t(.languageSectionTitle).uppercased())
                .font(.system(size: 9.5, weight: .bold, design: .rounded))
                .foregroundStyle(Palette.muted)
                .tracking(0.5)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 6) {
                ForEach(AppLanguage.allCases) { lang in
                    Button {
                        guard lang.isSelectable else { return }
                        loc.language = lang
                    } label: {
                        Text(lang.flag)
                            .font(.system(size: 15))
                            .frame(width: 28, height: 28)
                            .background(
                                Circle().fill(lang == loc.language ? Palette.accent.opacity(0.35) : Color.white.opacity(0.05))
                            )
                            .overlay(
                                Circle().stroke(lang == loc.language ? Palette.accent : Palette.border, lineWidth: lang == loc.language ? 1.5 : 1)
                            )
                            .opacity(lang.isSelectable ? 1 : 0.3)
                    }
                    .buttonStyle(.plain)
                    .disabled(!lang.isSelectable)
                    .help(lang.isSelectable ? lang.displayName : "\(lang.displayName) — недоступно")
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var toolbar: some View {
        HStack(spacing: 8) {
            Text(loc.t(.localSavedNote))
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(Palette.muted)
                .lineLimit(1)
                .layoutPriority(-1)
            Spacer(minLength: 8)
            PillButton(title: loc.t(.importButton), action: importBackup)
            PillButton(title: loc.t(.exportButton), action: exportBackup)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 4)
    }

    private func dropboxIfAvailable() -> URL? {
        let dropbox = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Dropbox")
        return FileManager.default.fileExists(atPath: dropbox.path) ? dropbox : nil
    }

    private func exportBackup() {
        let panel = NSSavePanel()
        panel.title = loc.t(.exportButton)
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
        panel.title = loc.t(.importButton)
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
        HStack(spacing: 8) {
            RoundedTextField(placeholder: loc.t(.wordPlaceholder), text: $newWord)
            RoundedTextField(placeholder: loc.t(.translationPlaceholder), text: $newTranslation)
            PillButton(title: loc.t(.addButton), filled: true) {
                if store.addWord(text: newWord, translation: newTranslation) {
                    newWord = ""
                    newTranslation = ""
                }
            }
            .disabled(newWord.trimmingCharacters(in: .whitespaces).isEmpty
                      || newTranslation.trimmingCharacters(in: .whitespaces).isEmpty)
            .keyboardShortcut(.return, modifiers: [])
        }
        .padding(16)
    }
}

// MARK: - Reusable pieces

private struct RoundedTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .font(.system(size: 13, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.06))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Palette.border, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct PillButton: View {
    let title: String
    var filled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .foregroundStyle(filled ? .black : .white)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(filled ? Color.white : Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(filled ? Color.clear : Palette.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .layoutPriority(1)
    }
}

private struct BucketColumn: View {
    @ObservedObject var store: Store
    @ObservedObject private var loc = Loc.shared
    let bucket: Bucket

    private var tint: Color { Palette.tint(for: bucket) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(tint)
                    Image(systemName: Palette.icon(for: bucket))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 30, height: 30)

                VStack(alignment: .leading, spacing: 0) {
                    Text(bucket.localizedName(loc.language))
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text("\(store.words(in: bucket).count) \(loc.t(.wordsCountSuffix))")
                        .font(.system(size: 10.5, design: .rounded))
                        .foregroundStyle(Palette.muted)
                }
                Spacer()
            }

            IntervalField(store: store, bucket: bucket, tint: tint)

            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(store.words(in: bucket)) { word in
                        WordRow(store: store, word: word, tint: tint)
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Palette.card)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Palette.border, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct IntervalField: View {
    @ObservedObject var store: Store
    @ObservedObject private var loc = Loc.shared
    let bucket: Bucket
    let tint: Color
    @State private var text: String = ""

    var body: some View {
        HStack(spacing: 6) {
            Text(loc.t(.everyLabel))
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(Palette.muted)
            TextField("", text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .frame(width: 36)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .onSubmit(commit)
            Text(loc.t(.minutesLabel))
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(Palette.muted)
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(tint.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
    @ObservedObject private var loc = Loc.shared
    let word: Word
    let tint: Color
    @State private var isEditing = false

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(word.text)
                    .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(word.translation)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Palette.muted)
            }
            Spacer()
            Menu {
                Button(loc.t(.editWordTitle) + "…") { isEditing = true }
                ForEach(Bucket.allCases.filter { $0 != word.bucket }) { target in
                    Button("→ \(target.localizedName(loc.language))") {
                        store.move(word, to: target)
                    }
                }
                Divider()
                Button(loc.t(.deleteButton), role: .destructive) {
                    store.deleteWord(word)
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .foregroundStyle(Palette.muted)
            }
            .menuStyle(.borderlessButton)
            .frame(width: 20)
        }
        .padding(9)
        .background(tint.opacity(0.1))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(tint.opacity(0.25), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture(count: 2) { isEditing = true }
        .sheet(isPresented: $isEditing) {
            EditWordView(store: store, word: word, isPresented: $isEditing)
        }
    }
}

private struct EditWordView: View {
    @ObservedObject var store: Store
    @ObservedObject private var loc = Loc.shared
    let word: Word
    @Binding var isPresented: Bool
    @State private var text: String
    @State private var translation: String

    init(store: Store, word: Word, isPresented: Binding<Bool>) {
        self.store = store
        self.word = word
        self._isPresented = isPresented
        self._text = State(initialValue: word.text)
        self._translation = State(initialValue: word.translation)
    }

    private var canSave: Bool {
        !text.trimmingCharacters(in: .whitespaces).isEmpty
            && !translation.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(loc.t(.editWordTitle))
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            RoundedTextField(placeholder: loc.t(.wordPlaceholder), text: $text)
            RoundedTextField(placeholder: loc.t(.translationPlaceholder), text: $translation)

            HStack {
                Spacer()
                PillButton(title: loc.t(.cancelButton)) { isPresented = false }
                PillButton(title: loc.t(.saveButton), filled: true) {
                    store.updateWord(word, text: text, translation: translation)
                    isPresented = false
                }
                .disabled(!canSave)
                .keyboardShortcut(.return, modifiers: [])
            }
        }
        .padding(24)
        .frame(width: 320)
        .background(Palette.bg)
        .preferredColorScheme(.dark)
    }
}
