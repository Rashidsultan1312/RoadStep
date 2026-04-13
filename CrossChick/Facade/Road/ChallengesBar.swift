import SwiftUI

struct ChallengesBar: View {
    @ObservedObject var cm = ChallengeManager.shared
    @EnvironmentObject var store: StepStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Daily Challenges")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(CC.text)
                Spacer()
                Text("\(cm.completedCount)/\(cm.totalCount)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(CC.accent)
            }

            ForEach(cm.today.challenges) { ch in
                challengeRow(ch)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(CC.surface))
        .onAppear { cm.refreshIfNeeded() }
    }

    private func challengeRow(_ ch: Challenge) -> some View {
        HStack(spacing: 10) {
            Image(systemName: ch.icon)
                .font(.system(size: 14))
                .foregroundStyle(ch.completed ? CC.accent : CC.textMuted)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 3) {
                Text(ch.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ch.completed ? CC.accent : CC.text)
                    .strikethrough(ch.completed)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(CC.card)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(ch.completed ? CC.accentGrad : CC.metalGrad)
                            .frame(width: geo.size.width * ch.progress)
                    }
                }
                .frame(height: 4)
            }

            Spacer()

            HStack(spacing: 2) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(CC.coin)
                Text("+\(ch.reward)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(ch.completed ? CC.coin : CC.textMuted)
            }
        }
    }
}
