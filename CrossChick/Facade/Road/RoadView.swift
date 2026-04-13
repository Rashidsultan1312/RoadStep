import SwiftUI

struct RoadView: View {
    @EnvironmentObject var store: StepStore

    var body: some View {
        ZStack {
            appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    topBar
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    RoadCanvasView(
                        currentLane: store.currentLane,
                        laneProgress: store.laneProgress,
                        mascotImage: store.activeMascot.imageName
                    )
                    .frame(height: 300)
                    .padding(.horizontal, 8)
                    .padding(.top, 20)

                    Text(motivationalText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(CC.textSecondary)
                        .padding(.top, 10)

                    statsRow
                        .padding(.horizontal, 30)
                        .padding(.top, 16)

                    ChallengesBar()
                        .padding(.horizontal, 12)
                        .padding(.top, 16)
                        .padding(.bottom, 16)

                    #if targetEnvironment(simulator)
                    debugRow
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                    #endif
                }
            }
        }
    }

    private var appBackground: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0x0F1128), Color(hex: 0x1A1D3A), Color(hex: 0x14162E)],
                startPoint: .top,
                endPoint: .bottom
            )

            Canvas { ctx, size in
                let stripes = 10
                let gap = size.width / CGFloat(stripes)

                for i in 1..<stripes {
                    let x = gap * CGFloat(i)

                    var dashPath = Path()
                    dashPath.move(to: CGPoint(x: x, y: 0))
                    dashPath.addLine(to: CGPoint(x: x, y: size.height))
                    ctx.stroke(dashPath, with: .color(.white.opacity(0.12)), style: StrokeStyle(lineWidth: 1.5, dash: [8, 14]))
                }
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 8) {
            Image(store.activeMascot.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 42)
                .clipShape(Circle())

            Spacer(minLength: 6)

            HStack(spacing: 4) {
                Image(systemName: "figure.walk")
                    .font(.system(size: 13))
                    .foregroundStyle(CC.accent)
                Text("\(store.todaySteps)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(CC.text)
                    .contentTransition(.numericText())
                Text("/ \(store.progress.dailyGoal)")
                    .font(.system(size: 11))
                    .foregroundStyle(CC.textMuted)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(CC.card.opacity(0.7))
            .clipShape(Capsule())

            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.orange)
                Text("\(store.progress.currentStreak)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(CC.text)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(CC.card.opacity(0.7))
            .clipShape(Capsule())

            HStack(spacing: 4) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(CC.coin)
                Text("\(store.progress.totalCoins)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(CC.coin)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(CC.card.opacity(0.7))
            .clipShape(Capsule())
        }
    }

    private var statsRow: some View {
        HStack {
            statItem(icon: "clock", value: stepTime, label: "Time")
            Spacer()
            statItem(icon: "flame", value: "\(Int(Double(store.todaySteps) * 0.04))", label: "Kcal")
            Spacer()
            statItem(icon: "location", value: String(format: "%.2f", store.distance(steps: store.todaySteps)), label: store.distanceLabel)
        }
    }

    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(CC.accent)
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(CC.text)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(CC.textMuted)
        }
        .frame(width: 70)
    }

    private var stepTime: String {
        let minutes = store.todaySteps / 100
        if minutes >= 60 {
            return "\(minutes / 60)h \(minutes % 60)m"
        }
        return "\(minutes)m"
    }

    private var motivationalText: String {
        if store.todaySteps >= store.progress.dailyGoal {
            return "Goal reached!"
        } else if store.currentLane >= 5 {
            return "Halfway there"
        } else if store.todaySteps == 0 {
            return "Start walking"
        } else {
            let spl = max(store.progress.stepsPerLane, 500)
            let remaining = spl - (store.todaySteps % spl)
            return "\(remaining) to next lane"
        }
    }

    #if targetEnvironment(simulator)
    private var debugRow: some View {
        HStack(spacing: 10) {
            ForEach([("+100", 100), ("+1K", 1000), ("+5K", 5000)], id: \.0) { label, val in
                Button(label) { store.addDebugSteps(val) }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(CC.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(CC.card)
                    .clipShape(Capsule())
            }
        }
    }
    #endif
}
