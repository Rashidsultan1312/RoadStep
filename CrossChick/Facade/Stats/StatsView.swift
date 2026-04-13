import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: StepStore

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    todaySection
                    weekSection
                    recordsSection
                }
                .padding(16)
            }
            .background(CC.bg)
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .task { await store.refreshHistory() }
        }
    }

    private var todaySection: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Today")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(CC.text)
                Spacer()
                Text("\(Int(store.goalProgress * 100))% of goal")
                    .font(.system(size: 13))
                    .foregroundStyle(store.goalProgress >= 1 ? CC.accent : CC.textMuted)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(CC.card)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(store.goalProgress >= 1 ? CC.coinGrad : CC.accentGrad)
                        .frame(width: geo.size.width * min(store.goalProgress, 1))
                        .animation(.easeInOut, value: store.goalProgress)
                }
            }
            .frame(height: 10)

            HStack(spacing: 0) {
                todayStat(value: "\(store.todaySteps)", label: "Steps")
                todayStat(value: String(format: "%.1f", store.distance(steps: store.todaySteps)), label: store.distanceLabel)
                todayStat(value: "\(Int(Double(store.todaySteps) * 0.04))", label: "Kcal")
                todayStat(value: "\(store.currentLane)", label: "Lanes")
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(CC.surface))
    }

    private func todayStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(CC.text)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(CC.textMuted)
        }
        .frame(maxWidth: .infinity)
    }

    private var weekSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(CC.text)

            if store.history.isEmpty {
                Text("No data yet")
                    .font(.system(size: 14))
                    .foregroundStyle(CC.textMuted)
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else {
                DayBarChart(records: store.history, goal: store.progress.dailyGoal)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(CC.surface))
    }

    private var recordsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Records")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(CC.text)
                Spacer()
            }

            HStack(alignment: .top, spacing: 12) {
                recordCard(icon: "flame.fill", color: .orange, value: "\(store.progress.currentStreak)", label: "Current Streak", sub: "Best: \(store.progress.bestStreak)")
                recordCard(icon: "star.circle.fill", color: CC.coin, value: "\(store.progress.totalCoins)", label: "Total Stars", sub: "")
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func recordCard(icon: String, color: Color, value: String, label: String, sub: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(CC.text)

            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(CC.textMuted)

            Text(sub.isEmpty ? " " : sub)
                .font(.system(size: 11))
                .foregroundStyle(CC.textMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(CC.surface))
    }
}
