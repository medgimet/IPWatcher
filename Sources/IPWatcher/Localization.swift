import Foundation

enum AppLanguage: String, Codable, CaseIterable {
    case en, pl

    var displayName: String {
        switch self {
        case .en: return "English"
        case .pl: return "Polski"
        }
    }
}

enum L10nKey {
    case settingsTitle, targetIP, intervalSeconds, hideIP, save, enterTargetIP
    case menuSettings, menuCheckNow, menuHistory, menuQuit
    case noHistory, ipChangedTitle, error
    case language
}

private let strings: [AppLanguage: [L10nKey: String]] = [
    .en: [
        .settingsTitle: "IPWatcher — Settings",
        .targetIP: "Target IP:",
        .intervalSeconds: "Interval (sec):",
        .hideIP: "Hide IP in menu bar",
        .save: "Save",
        .enterTargetIP: "Enter target IP address",
        .menuSettings: "Settings…",
        .menuCheckNow: "Check now",
        .menuHistory: "History",
        .menuQuit: "Quit",
        .noHistory: "No changes recorded yet",
        .ipChangedTitle: "IP changed!",
        .error: "error",
        .language: "Language:",
    ],
    .pl: [
        .settingsTitle: "IPWatcher — Ustawienia",
        .targetIP: "Docelowe IP:",
        .intervalSeconds: "Interwał (sek):",
        .hideIP: "Ukryj IP w pasku menu",
        .save: "Zapisz",
        .enterTargetIP: "Wprowadź docelowy adres IP",
        .menuSettings: "Ustawienia…",
        .menuCheckNow: "Sprawdź teraz",
        .menuHistory: "Historia",
        .menuQuit: "Zakończ",
        .noHistory: "Brak zarejestrowanych zmian",
        .ipChangedTitle: "Adres IP się zmienił!",
        .error: "błąd",
        .language: "Język:",
    ],
]

enum L10n {
    static var current: AppLanguage = .en

    static func t(_ key: L10nKey) -> String {
        strings[current]?[key] ?? strings[.en]?[key] ?? ""
    }
}
