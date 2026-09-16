import Foundation

enum Bucket: String, CaseIterable, Identifiable {
    case bad = "Не знаю"
    case medium = "Вчу"
    case good = "Знаю"

    var id: String { rawValue }

    /// Old label saved on disk before the rename, so existing data keeps loading.
    static func legacyMigratedKey(_ raw: String) -> String {
        switch raw {
        case "Погано знаю": return Bucket.bad.rawValue
        case "Середньо": return Bucket.medium.rawValue
        case "Добре знаю": return Bucket.good.rawValue
        default: return raw
        }
    }
}

extension Bucket: Codable {
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = Bucket(rawValue: Bucket.legacyMigratedKey(raw)) ?? .bad
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
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

    /// Remaps any pre-rename keys ("Погано знаю" etc.) to the current labels.
    mutating func migrateLegacyKeys() {
        var migrated: [String: Double] = [:]
        for (key, value) in intervalMinutes {
            migrated[Bucket.legacyMigratedKey(key)] = value
        }
        intervalMinutes = migrated
    }
}

struct Backup: Codable {
    var words: [Word]
    var settings: BucketSettings
}
