import Foundation

enum Bucket: String, Codable, CaseIterable, Identifiable {
    case bad = "Погано знаю"
    case medium = "Середньо"
    case good = "Добре знаю"

    var id: String { rawValue }
}

struct Word: Codable, Identifiable, Equatable {
    let id: UUID
    var text: String
    var translation: String
    var bucket: Bucket
    var dateAdded: Date

    init(text: String, translation: String, bucket: Bucket = .bad) {
        self.id = UUID()
        self.text = text
        self.translation = translation
        self.bucket = bucket
        self.dateAdded = Date()
    }
}

struct BucketSettings: Codable {
    var intervalMinutes: [String: Double]

    static let `default` = BucketSettings(intervalMinutes: [
        Bucket.bad.rawValue: 15,
        Bucket.medium.rawValue: 30,
        Bucket.good.rawValue: 60
    ])

    func interval(for bucket: Bucket) -> Double {
        intervalMinutes[bucket.rawValue] ?? BucketSettings.default.intervalMinutes[bucket.rawValue] ?? 30
    }

    mutating func setInterval(_ minutes: Double, for bucket: Bucket) {
        intervalMinutes[bucket.rawValue] = minutes
    }
}

struct Backup: Codable {
    var words: [Word]
    var settings: BucketSettings
}
