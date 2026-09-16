import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    /// Free tier: up to this many words total. Above it, addWord() refuses
    /// unless isPremium is set. $5/year unlock — payment flow TBD (App
    /// Store vs. Stripe, still being decided), isPremium is a manual
    /// placeholder toggle until that's wired up.
    static let freeWordLimit = 10

    @Published var words: [Word] = []
    @Published var settings: BucketSettings = .default
    @Published var wordToShow: Word?
    @Published var isPremium: Bool {
        didSet { UserDefaults.standard.set(isPremium, forKey: "isPremium") }
    }

    var canAddMoreWords: Bool { isPremium || words.count < Store.freeWordLimit }

    private var timers: [Bucket: Timer] = [:]

    private let wordsURL: URL
    private let settingsURL: URL

    init() {
        isPremium = UserDefaults.standard.bool(forKey: "isPremium")

        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("WordTrainer", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        wordsURL = dir.appendingPathComponent("words.json")
        settingsURL = dir.appendingPathComponent("settings.json")

        load()
        restartAllTimers()
    }

    // MARK: - Persistence

    private func load() {
        if let data = try? Data(contentsOf: wordsURL),
           let decoded = try? JSONDecoder().decode([Word].self, from: data) {
            words = decoded
        }
        if let data = try? Data(contentsOf: settingsURL),
           var decoded = try? JSONDecoder().decode(BucketSettings.self, from: data) {
            decoded.migrateLegacyKeys()
            settings = decoded
        }
    }

    private func saveWords() {
        guard let data = try? JSONEncoder().encode(words) else { return }
        try? data.write(to: wordsURL, options: .atomic)
    }

    private func saveSettings() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        try? data.write(to: settingsURL, options: .atomic)
    }

    // MARK: - Word management

    @discardableResult
    func addWord(text: String, translation: String) -> Bool {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTranslation = translation.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty, !trimmedTranslation.isEmpty else { return false }
        guard canAddMoreWords else { return false }
        words.append(Word(text: trimmedText, translation: trimmedTranslation))
        saveWords()
        return true
    }

    func updateWord(_ word: Word, text: String, translation: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTranslation = translation.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty, !trimmedTranslation.isEmpty else { return }
        guard let index = words.firstIndex(where: { $0.id == word.id }) else { return }
        words[index].text = trimmedText
        words[index].translation = trimmedTranslation
        saveWords()
    }

    func deleteWord(_ word: Word) {
        words.removeAll { $0.id == word.id }
        saveWords()
    }

    func move(_ word: Word, to bucket: Bucket) {
        guard let index = words.firstIndex(where: { $0.id == word.id }) else { return }
        words[index].bucket = bucket
        saveWords()
    }

    func words(in bucket: Bucket) -> [Word] {
        words.filter { $0.bucket == bucket }
    }

    // MARK: - Timers

    func setInterval(_ minutes: Double, for bucket: Bucket) {
        settings.setInterval(minutes, for: bucket)
        saveSettings()
        restartTimer(for: bucket)
    }

    func restartAllTimers() {
        for bucket in Bucket.allCases {
            restartTimer(for: bucket)
        }
    }

    private func restartTimer(for bucket: Bucket) {
        timers[bucket]?.invalidate()
        let interval = settings.interval(for: bucket) * 60
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.popRandomWord(from: bucket)
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        timers[bucket] = timer
    }

    private func popRandomWord(from bucket: Bucket) {
        let candidates = words(in: bucket)
        guard let word = candidates.randomElement() else { return }
        wordToShow = word
    }

    // MARK: - Backup / Restore

    func exportBackup(to url: URL) throws {
        let backup = Backup(words: words, settings: settings)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(backup)
        try data.write(to: url, options: .atomic)
    }

    func importBackup(from url: URL) throws {
        let data = try Data(contentsOf: url)
        let backup = try JSONDecoder().decode(Backup.self, from: data)
        words = backup.words
        settings = backup.settings
        saveWords()
        saveSettings()
        restartAllTimers()
    }
}
