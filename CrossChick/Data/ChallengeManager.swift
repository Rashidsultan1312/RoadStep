import Foundation

struct Challenge: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let type: ChallengeType
    let target: Int
    var current: Int = 0
    let reward: Int
    var completed: Bool = false

    var progress: Double { min(Double(current) / Double(max(target, 1)), 1.0) }
}

enum ChallengeType: String, Codable {
    case totalSteps
    case lanesInRow
    case stepsInTime
    case crossings
    case noBreak
}

struct DailyChallenges: Codable {
    var dateKey: String
    var challenges: [Challenge]
}

@MainActor
final class ChallengeManager: ObservableObject {
    static let shared = ChallengeManager()

    @Published var today: DailyChallenges = DailyChallenges(dateKey: "", challenges: [])

    private let storageKey = "cc_challenges_v1"

    private init() { load() }

    func refreshIfNeeded() {
        let key = Self.todayKey()
        if today.dateKey != key {
            today = DailyChallenges(dateKey: key, challenges: generateChallenges())
            save()
        }
    }

    func updateProgress(steps: Int, lanes: Int, crossings: Int) {
        var changed = false
        for i in today.challenges.indices {
            guard !today.challenges[i].completed else { continue }

            switch today.challenges[i].type {
            case .totalSteps:
                today.challenges[i].current = steps
            case .lanesInRow:
                today.challenges[i].current = lanes
            case .crossings:
                today.challenges[i].current = crossings
            case .stepsInTime, .noBreak:
                today.challenges[i].current = steps
            }

            if today.challenges[i].current >= today.challenges[i].target && !today.challenges[i].completed {
                today.challenges[i].completed = true
                changed = true
            }
        }
        if changed { save() }
    }

    func claimReward(for id: String) -> Int {
        guard let idx = today.challenges.firstIndex(where: { $0.id == id && $0.completed }) else { return 0 }
        let reward = today.challenges[idx].reward
        today.challenges[idx] = today.challenges[idx]
        save()
        return reward
    }

    var completedCount: Int { today.challenges.filter(\.completed).count }
    var totalCount: Int { today.challenges.count }

    private func generateChallenges() -> [Challenge] {
        let pool: [Challenge] = [
            Challenge(id: "steps_3k", title: "Quick Walk", description: "Walk 3,000 steps", icon: "figure.walk", type: .totalSteps, target: 3000, reward: 5),
            Challenge(id: "steps_5k", title: "Morning Jog", description: "Walk 5,000 steps", icon: "figure.run", type: .totalSteps, target: 5000, reward: 8),
            Challenge(id: "steps_8k", title: "Power Walk", description: "Walk 8,000 steps", icon: "bolt.fill", type: .totalSteps, target: 8000, reward: 12),
            Challenge(id: "steps_12k", title: "Marathon Day", description: "Walk 12,000 steps", icon: "trophy.fill", type: .totalSteps, target: 12000, reward: 20),
            Challenge(id: "lanes_3", title: "Triple Lane", description: "Cross 3 lanes", icon: "road.lanes", type: .lanesInRow, target: 3, reward: 5),
            Challenge(id: "lanes_5", title: "Five Lanes", description: "Cross 5 lanes", icon: "road.lanes", type: .lanesInRow, target: 5, reward: 8),
            Challenge(id: "lanes_8", title: "Road Runner", description: "Cross 8 lanes", icon: "hare.fill", type: .lanesInRow, target: 8, reward: 15),
            Challenge(id: "cross_1", title: "Full Cross", description: "Complete 1 full crossing", icon: "flag.checkered", type: .crossings, target: 1, reward: 15),
            Challenge(id: "cross_2", title: "Double Cross", description: "Complete 2 crossings", icon: "flag.checkered.2.crossed", type: .crossings, target: 2, reward: 30),
        ]

        var shuffled = pool.shuffled()
        let easy = shuffled.first { $0.target <= 5000 || $0.type == .lanesInRow && $0.target <= 3 }
        let medium = shuffled.first { ($0.target > 5000 && $0.target <= 8000) || $0.type == .lanesInRow && $0.target > 3 }
        let hard = shuffled.first { $0.target > 8000 || $0.type == .crossings }

        return [easy, medium, hard].compactMap { $0 }.isEmpty
            ? Array(shuffled.prefix(3))
            : [easy, medium, hard].compactMap { $0 }
    }

    private static func todayKey() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: Date())
    }

    private func save() {
        if let data = try? JSONEncoder().encode(today) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let saved = try? JSONDecoder().decode(DailyChallenges.self, from: data) else { return }
        today = saved
    }
}
