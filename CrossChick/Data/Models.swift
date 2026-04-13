import Foundation

struct Mascot: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let imageName: String
    let cost: Int
    let category: MascotCategory
}

enum MascotCategory: String, Codable, CaseIterable {
    case free
    case common
    case rare
    case legendary

    var label: String {
        switch self {
        case .free: "Free"
        case .common: "Common"
        case .rare: "Rare"
        case .legendary: "Legendary"
        }
    }
}

struct DayRecord: Identifiable, Codable {
    var id: String { dateKey }
    let dateKey: String
    var steps: Int
    var lanesCompleted: Int
    var fullCrossings: Int
    var coinsEarned: Int
}

struct UserProgress: Codable {
    var totalCoins: Int = 0
    var unlockedMascotIDs: [String] = ["runner"]
    var activeMascotID: String = "runner"
    var dailyGoal: Int = 10000
    var weeklyGoal: Int = 50000
    var currentStreak: Int = 0
    var bestStreak: Int = 0
    var lastActiveDate: String?
    var totalStepsAllTime: Int = 0
    var notificationsEnabled: Bool = true
    var inactivityMinutes: Int = 60
    var morningReminderHour: Int = 8
    var lastLaneAwarded: Int = 0
    var lastCrossingAwarded: Int = 0
    var unitSystem: Int = 0 // 0 = metric, 1 = imperial
    var stepsPerLane: Int = 1000
    var hapticEnabled: Bool = true
}
