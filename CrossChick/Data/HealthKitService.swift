import Foundation
import CoreMotion
import HealthKit

final class HealthKitService {
    private let pedometer = CMPedometer()
    private let healthStore = HKHealthStore()
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

    var isPedometerAvailable: Bool { CMPedometer.isStepCountingAvailable() }
    var isHealthKitAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    func requestAuthorization() async throws {
        guard isHealthKitAvailable else { return }
        let share: Set<HKSampleType> = [HKWorkoutType.workoutType()]
        let read: Set<HKObjectType> = [stepType]
        try await healthStore.requestAuthorization(toShare: share, read: read)
    }

    func todaySteps() async throws -> Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        return try await withCheckedThrowingContinuation { cont in
            pedometer.queryPedometerData(from: start, to: Date()) { data, err in
                if let err { cont.resume(throwing: err); return }
                cont.resume(returning: data?.numberOfSteps.intValue ?? 0)
            }
        }
    }

    func startLiveUpdates(handler: @escaping (Int) -> Void) {
        let start = Calendar.current.startOfDay(for: Date())
        pedometer.startUpdates(from: start) { data, _ in
            guard let steps = data?.numberOfSteps.intValue else { return }
            DispatchQueue.main.async { handler(steps) }
        }
    }

    func stopLiveUpdates() {
        pedometer.stopUpdates()
    }

    func saveWalkingWorkout(steps: Int, distance: Double) async {
        guard isHealthKitAvailable else { return }
        let duration: TimeInterval = Double(steps) / 1.67
        let workout = HKWorkout(
            activityType: .walking,
            start: Date().addingTimeInterval(-duration),
            end: Date(),
            duration: duration,
            totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: Double(steps) * 0.04),
            totalDistance: HKQuantity(unit: .meter(), doubleValue: distance),
            metadata: nil
        )
        do {
            try await healthStore.save(workout)
        } catch {}
    }

    func stepHistory(days: Int) async throws -> [(String, Int)] {
        let cal = Calendar.current
        var results: [(String, Int)] = []
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"

        for i in 0..<days {
            guard let dayStart = cal.date(byAdding: .day, value: -i, to: cal.startOfDay(for: Date())),
                  let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart) else { continue }

            let predicate = HKQuery.predicateForSamples(withStart: dayStart, end: dayEnd)
            let desc = HKStatisticsCollectionQuery.init(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: dayStart,
                intervalComponents: DateComponents(day: 1)
            )

            let steps: Int = try await withCheckedThrowingContinuation { cont in
                desc.initialResultsHandler = { _, collection, err in
                    if let err { cont.resume(throwing: err); return }
                    let sum = collection?.statistics().first?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    cont.resume(returning: Int(sum))
                }
                healthStore.execute(desc)
            }
            results.append((fmt.string(from: dayStart), steps))
        }
        return results
    }
}
