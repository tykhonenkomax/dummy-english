import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case uk, en, es, fr, de, it, pt, pl, tr, ja
    case ru // shown in the picker but intentionally not selectable

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .uk: return "Українська"
        case .en: return "English"
        case .es: return "Español"
        case .fr: return "Français"
        case .de: return "Deutsch"
        case .it: return "Italiano"
        case .pt: return "Português"
        case .pl: return "Polski"
        case .tr: return "Türkçe"
        case .ja: return "日本語"
        case .ru: return "Русский"
        }
    }

    var flag: String {
        switch self {
        case .uk: return "🇺🇦"
        case .en: return "🇬🇧"
        case .es: return "🇪🇸"
        case .fr: return "🇫🇷"
        case .de: return "🇩🇪"
        case .it: return "🇮🇹"
        case .pt: return "🇵🇹"
        case .pl: return "🇵🇱"
        case .tr: return "🇹🇷"
        case .ja: return "🇯🇵"
        case .ru: return "🇷🇺"
        }
    }

    var isSelectable: Bool { self != .ru }

    static var current: AppLanguage {
        get {
            if let raw = UserDefaults.standard.string(forKey: "appLanguage"),
               let lang = AppLanguage(rawValue: raw), lang.isSelectable {
                return lang
            }
            return .en
        }
        set {
            guard newValue.isSelectable else { return }
            UserDefaults.standard.set(newValue.rawValue, forKey: "appLanguage")
        }
    }
}

enum LKey {
    case adminMenuItem, showWordNow, quitMenuItem
    case wordPlaceholder, translationPlaceholder, addButton
    case cancelButton, saveButton, editWordTitle, deleteButton
    case importButton, exportButton
    case everyLabel, minutesLabel
    case bucketBad, bucketMedium, bucketGood
    case wordsCountSuffix
    case limitBannerText, learnMoreButton
    case localSavedNote
    case adminWindowTitleSuffix
    case languageSectionTitle
}

private let translations: [AppLanguage: [LKey: String]] = [
    .uk: [
        .adminMenuItem: "Адмінка…", .showWordNow: "Показати слово зараз", .quitMenuItem: "Вийти",
        .wordPlaceholder: "Слово (англ.)", .translationPlaceholder: "Переклад", .addButton: "Додати",
        .cancelButton: "Скасувати", .saveButton: "Зберегти", .editWordTitle: "Редагувати слово", .deleteButton: "Видалити",
        .importButton: "Імпорт бази…", .exportButton: "Експорт бази…",
        .everyLabel: "Кожні", .minutesLabel: "хв",
        .bucketBad: "Не знаю", .bucketMedium: "Вчу", .bucketGood: "Знаю",
        .wordsCountSuffix: "слів",
        .limitBannerText: "Безкоштовно доступно %d слів. Більше — преміум за $5/рік.",
        .learnMoreButton: "Дізнатись більше",
        .localSavedNote: "База зберігається локально на цьому Mac.",
        .adminWindowTitleSuffix: "— Адмінка",
        .languageSectionTitle: "Мова"
    ],
    .en: [
        .adminMenuItem: "Admin…", .showWordNow: "Show a word now", .quitMenuItem: "Quit",
        .wordPlaceholder: "Word (English)", .translationPlaceholder: "Translation", .addButton: "Add",
        .cancelButton: "Cancel", .saveButton: "Save", .editWordTitle: "Edit word", .deleteButton: "Delete",
        .importButton: "Import backup…", .exportButton: "Export backup…",
        .everyLabel: "Every", .minutesLabel: "min",
        .bucketBad: "Don't know", .bucketMedium: "Learning", .bucketGood: "Know",
        .wordsCountSuffix: "words",
        .limitBannerText: "Free tier: up to %d words. More — premium for $5/year.",
        .learnMoreButton: "Learn more",
        .localSavedNote: "Your data is stored locally on this Mac.",
        .adminWindowTitleSuffix: "— Admin",
        .languageSectionTitle: "Language"
    ],
    .es: [
        .adminMenuItem: "Administrar…", .showWordNow: "Mostrar una palabra ahora", .quitMenuItem: "Salir",
        .wordPlaceholder: "Palabra (inglés)", .translationPlaceholder: "Traducción", .addButton: "Añadir",
        .cancelButton: "Cancelar", .saveButton: "Guardar", .editWordTitle: "Editar palabra", .deleteButton: "Eliminar",
        .importButton: "Importar copia…", .exportButton: "Exportar copia…",
        .everyLabel: "Cada", .minutesLabel: "min",
        .bucketBad: "No lo sé", .bucketMedium: "Aprendiendo", .bucketGood: "Lo sé",
        .wordsCountSuffix: "palabras",
        .limitBannerText: "Gratis hasta %d palabras. Más — premium por $5/año.",
        .learnMoreButton: "Saber más",
        .localSavedNote: "Tus datos se guardan localmente en este Mac.",
        .adminWindowTitleSuffix: "— Administrar",
        .languageSectionTitle: "Idioma"
    ],
    .fr: [
        .adminMenuItem: "Administration…", .showWordNow: "Afficher un mot maintenant", .quitMenuItem: "Quitter",
        .wordPlaceholder: "Mot (anglais)", .translationPlaceholder: "Traduction", .addButton: "Ajouter",
        .cancelButton: "Annuler", .saveButton: "Enregistrer", .editWordTitle: "Modifier le mot", .deleteButton: "Supprimer",
        .importButton: "Importer une sauvegarde…", .exportButton: "Exporter une sauvegarde…",
        .everyLabel: "Toutes les", .minutesLabel: "min",
        .bucketBad: "Je ne sais pas", .bucketMedium: "J'apprends", .bucketGood: "Je sais",
        .wordsCountSuffix: "mots",
        .limitBannerText: "Gratuit jusqu'à %d mots. Au-delà — premium à 5 $/an.",
        .learnMoreButton: "En savoir plus",
        .localSavedNote: "Tes données sont stockées localement sur ce Mac.",
        .adminWindowTitleSuffix: "— Administration",
        .languageSectionTitle: "Langue"
    ],
    .de: [
        .adminMenuItem: "Verwaltung…", .showWordNow: "Jetzt ein Wort zeigen", .quitMenuItem: "Beenden",
        .wordPlaceholder: "Wort (Englisch)", .translationPlaceholder: "Übersetzung", .addButton: "Hinzufügen",
        .cancelButton: "Abbrechen", .saveButton: "Speichern", .editWordTitle: "Wort bearbeiten", .deleteButton: "Löschen",
        .importButton: "Backup importieren…", .exportButton: "Backup exportieren…",
        .everyLabel: "Alle", .minutesLabel: "Min",
        .bucketBad: "Weiß ich nicht", .bucketMedium: "Lerne ich", .bucketGood: "Weiß ich",
        .wordsCountSuffix: "Wörter",
        .limitBannerText: "Kostenlos bis zu %d Wörter. Mehr — Premium für 5 $/Jahr.",
        .learnMoreButton: "Mehr erfahren",
        .localSavedNote: "Deine Daten werden lokal auf diesem Mac gespeichert.",
        .adminWindowTitleSuffix: "— Verwaltung",
        .languageSectionTitle: "Sprache"
    ],
    .it: [
        .adminMenuItem: "Amministrazione…", .showWordNow: "Mostra una parola ora", .quitMenuItem: "Esci",
        .wordPlaceholder: "Parola (inglese)", .translationPlaceholder: "Traduzione", .addButton: "Aggiungi",
        .cancelButton: "Annulla", .saveButton: "Salva", .editWordTitle: "Modifica parola", .deleteButton: "Elimina",
        .importButton: "Importa backup…", .exportButton: "Esporta backup…",
        .everyLabel: "Ogni", .minutesLabel: "min",
        .bucketBad: "Non lo so", .bucketMedium: "Sto imparando", .bucketGood: "Lo so",
        .wordsCountSuffix: "parole",
        .limitBannerText: "Gratis fino a %d parole. Oltre — premium a $5/anno.",
        .learnMoreButton: "Scopri di più",
        .localSavedNote: "I tuoi dati sono salvati localmente su questo Mac.",
        .adminWindowTitleSuffix: "— Amministrazione",
        .languageSectionTitle: "Lingua"
    ],
    .pt: [
        .adminMenuItem: "Administração…", .showWordNow: "Mostrar uma palavra agora", .quitMenuItem: "Sair",
        .wordPlaceholder: "Palavra (inglês)", .translationPlaceholder: "Tradução", .addButton: "Adicionar",
        .cancelButton: "Cancelar", .saveButton: "Guardar", .editWordTitle: "Editar palavra", .deleteButton: "Eliminar",
        .importButton: "Importar backup…", .exportButton: "Exportar backup…",
        .everyLabel: "A cada", .minutesLabel: "min",
        .bucketBad: "Não sei", .bucketMedium: "A aprender", .bucketGood: "Sei",
        .wordsCountSuffix: "palavras",
        .limitBannerText: "Grátis até %d palavras. Mais — premium por $5/ano.",
        .learnMoreButton: "Saber mais",
        .localSavedNote: "Os teus dados ficam guardados localmente neste Mac.",
        .adminWindowTitleSuffix: "— Administração",
        .languageSectionTitle: "Idioma"
    ],
    .pl: [
        .adminMenuItem: "Panel…", .showWordNow: "Pokaż słowo teraz", .quitMenuItem: "Zamknij",
        .wordPlaceholder: "Słowo (ang.)", .translationPlaceholder: "Tłumaczenie", .addButton: "Dodaj",
        .cancelButton: "Anuluj", .saveButton: "Zapisz", .editWordTitle: "Edytuj słowo", .deleteButton: "Usuń",
        .importButton: "Importuj kopię…", .exportButton: "Eksportuj kopię…",
        .everyLabel: "Co", .minutesLabel: "min",
        .bucketBad: "Nie znam", .bucketMedium: "Uczę się", .bucketGood: "Znam",
        .wordsCountSuffix: "słów",
        .limitBannerText: "Bezpłatnie do %d słów. Więcej — premium za 5 USD/rok.",
        .learnMoreButton: "Dowiedz się więcej",
        .localSavedNote: "Twoje dane są zapisywane lokalnie na tym Macu.",
        .adminWindowTitleSuffix: "— Panel",
        .languageSectionTitle: "Język"
    ],
    .tr: [
        .adminMenuItem: "Yönetim…", .showWordNow: "Şimdi bir kelime göster", .quitMenuItem: "Çıkış",
        .wordPlaceholder: "Kelime (İngilizce)", .translationPlaceholder: "Çeviri", .addButton: "Ekle",
        .cancelButton: "İptal", .saveButton: "Kaydet", .editWordTitle: "Kelimeyi düzenle", .deleteButton: "Sil",
        .importButton: "Yedek içe aktar…", .exportButton: "Yedek dışa aktar…",
        .everyLabel: "Her", .minutesLabel: "dk",
        .bucketBad: "Bilmiyorum", .bucketMedium: "Öğreniyorum", .bucketGood: "Biliyorum",
        .wordsCountSuffix: "kelime",
        .limitBannerText: "Ücretsiz %d kelimeye kadar. Fazlası — yılda 5$ premium.",
        .learnMoreButton: "Daha fazla bilgi",
        .localSavedNote: "Verilerin bu Mac'te yerel olarak saklanır.",
        .adminWindowTitleSuffix: "— Yönetim",
        .languageSectionTitle: "Dil"
    ],
    .ja: [
        .adminMenuItem: "管理…", .showWordNow: "今すぐ単語を表示", .quitMenuItem: "終了",
        .wordPlaceholder: "単語（英語）", .translationPlaceholder: "訳", .addButton: "追加",
        .cancelButton: "キャンセル", .saveButton: "保存", .editWordTitle: "単語を編集", .deleteButton: "削除",
        .importButton: "バックアップを読み込む…", .exportButton: "バックアップを書き出す…",
        .everyLabel: "間隔", .minutesLabel: "分",
        .bucketBad: "知らない", .bucketMedium: "学習中", .bucketGood: "知ってる",
        .wordsCountSuffix: "単語",
        .limitBannerText: "無料で%d単語まで。それ以上はプレミアム（年$5）。",
        .learnMoreButton: "詳しく見る",
        .localSavedNote: "データはこのMacにローカル保存されます。",
        .adminWindowTitleSuffix: "— 管理",
        .languageSectionTitle: "言語"
    ]
]

func L(_ key: LKey) -> String {
    translations[AppLanguage.current]?[key] ?? translations[.en]?[key] ?? ""
}

func L(_ key: LKey, _ language: AppLanguage) -> String {
    translations[language]?[key] ?? translations[.en]?[key] ?? ""
}

/// Publishes language changes so SwiftUI views actually re-render when the
/// picker changes it (a free `L()` read alone doesn't establish that
/// dependency for SwiftUI's diffing).
@MainActor
final class Loc: ObservableObject {
    static let shared = Loc()
    @Published var language: AppLanguage = .current {
        didSet { AppLanguage.current = language }
    }
    func t(_ key: LKey) -> String { L(key, language) }
}

extension Bucket {
    func localizedName(_ language: AppLanguage = .current) -> String {
        switch self {
        case .bad: return L(.bucketBad, language)
        case .medium: return L(.bucketMedium, language)
        case .good: return L(.bucketGood, language)
        }
    }
}
