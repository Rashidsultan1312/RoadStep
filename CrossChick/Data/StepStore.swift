import SwiftUI
import Combine

@MainActor
final class StepStore: ObservableObject {
    static let shared = StepStore()

    @Published var todaySteps: Int = 0
    @Published var history: [DayRecord] = []
    @Published var progress: UserProgress = .init()
    @Published var isLoading = true

    private let hk = HealthKitService()
    private let progressKey = "cc_progress_v1"
    private let historyKey = "cc_history_v1"

    private var spl: Int { max(progress.stepsPerLane, 500) }
    private var crossingSteps: Int { spl * 10 }
    var currentLane: Int { (todaySteps % crossingSteps) / spl }
    var laneProgress: Double { Double(todaySteps % spl) / Double(spl) }
    var fullCrossings: Int { todaySteps / crossingSteps }
    var goalProgress: Double { min(Double(todaySteps) / Double(max(progress.dailyGoal, 1)), 1.0) }

    var isMetric: Bool { progress.unitSystem == 0 }
    var distanceLabel: String { isMetric ? "Km" : "Mi" }
    func distance(steps: Int) -> Double {
        let km = Double(steps) / 1312.0
        return isMetric ? km : km * 0.6214
    }

    var activeMascot: Mascot {
        MascotCatalog.find(progress.activeMascotID) ?? MascotCatalog.all[0]
    }

    private init() {
        loadProgress()
        loadHistory()
    }

    func loadIfNeeded() async {
        guard isLoading else { return }

        NotificationService.shared.refresh(enabled: progress.notificationsEnabled, inactivityMinutes: progress.inactivityMinutes)

        #if targetEnvironment(simulator)
        todaySteps = 0
        updateStreak()
        isLoading = false
        #else
        do {
            try await hk.requestAuthorization()
        } catch {}
        if let steps = try? await hk.todaySteps() {
            todaySteps = steps
        }
        startLive()
        updateStreak()
        isLoading = false
        #endif
    }

    func startLive() {
        hk.startLiveUpdates { [weak self] steps in
            Task { @MainActor in
                guard let self else { return }
                self.todaySteps = steps
                self.checkRewards()
            }
        }
    }

    func checkRewards() {
        let lane = currentLane
        let crossing = fullCrossings

        ChallengeManager.shared.updateProgress(steps: todaySteps, lanes: lane, crossings: crossing)

        var earned = 0

        if lane > progress.lastLaneAwarded {
            let newLanes = lane - progress.lastLaneAwarded
            earned += newLanes
            progress.lastLaneAwarded = lane
        }

        if crossing > progress.lastCrossingAwarded {
            let newCrossings = crossing - progress.lastCrossingAwarded
            earned += newCrossings * 15
            progress.lastCrossingAwarded = crossing
            Task {
                await hk.saveWalkingWorkout(steps: crossingSteps * newCrossings, distance: Double(crossingSteps * newCrossings) / 1.312)
            }
        }

        if todaySteps >= progress.dailyGoal && progress.lastActiveDate != todayKey() {
            earned += 5
            if progress.notificationsEnabled {
                NotificationService.shared.sendGoalReached(steps: todaySteps)
            }
        }

        if earned > 0 {
            progress.totalCoins += earned
            progress.totalStepsAllTime = max(progress.totalStepsAllTime, todaySteps)
            save()
        }

        if progress.notificationsEnabled {
            NotificationService.shared.scheduleInactivityAlert(minutes: progress.inactivityMinutes)
        }
    }

    func unlockMascot(_ id: String) -> Bool {
        guard let mascot = MascotCatalog.find(id),
              progress.totalCoins >= mascot.cost,
              !progress.unlockedMascotIDs.contains(id) else { return false }
        progress.totalCoins -= mascot.cost
        progress.unlockedMascotIDs.append(id)
        save()
        return true
    }

    func setActiveMascot(_ id: String) {
        guard progress.unlockedMascotIDs.contains(id) else { return }
        progress.activeMascotID = id
        save()
    }

    func resetAll() {
        progress = UserProgress()
        todaySteps = 0
        history = []
        save()
        UserDefaults.standard.removeObject(forKey: historyKey)
        UserDefaults.standard.removeObject(forKey: "cc_challenges_v1")
        ChallengeManager.shared.today = DailyChallenges(dateKey: "", challenges: [])
        ChallengeManager.shared.refreshIfNeeded()
        NotificationService.shared.cancelAll()
    }

    func addDebugSteps(_ n: Int) {
        todaySteps += n
        checkRewards()
    }

    private func updateStreak() {
        let today = todayKey()
        guard let last = progress.lastActiveDate else {
            progress.lastActiveDate = today
            progress.currentStreak = 1
            save()
            return
        }
        if last == today { return }

        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        if let lastDate = fmt.date(from: last),
           let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date())),
           Calendar.current.isDate(lastDate, inSameDayAs: yesterday) {
            progress.currentStreak += 1
        } else if last != today {
            progress.currentStreak = 1
        }
        progress.bestStreak = max(progress.bestStreak, progress.currentStreak)
        progress.lastActiveDate = today
        progress.lastLaneAwarded = 0
        progress.lastCrossingAwarded = 0
        save()
    }

    private func todayKey() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: Date())
    }

    func save() {
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: progressKey)
        }
    }

    private func loadProgress() {
        guard let data = UserDefaults.standard.data(forKey: progressKey),
              let p = try? JSONDecoder().decode(UserProgress.self, from: data) else { return }
        progress = p
    }

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let h = try? JSONDecoder().decode([DayRecord].self, from: data) else { return }
        history = h
    }

    func refreshHistory() async {
        guard let raw = try? await hk.stepHistory(days: 7) else { return }
        history = raw.map { key, steps in
            DayRecord(
                dateKey: key,
                steps: steps,
                lanesCompleted: min(steps / spl, 10),
                fullCrossings: steps / crossingSteps,
                coinsEarned: min(steps / spl, 10) + (steps / crossingSteps) * 15
            )
        }
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }
}
