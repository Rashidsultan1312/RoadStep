import SwiftUI

struct DayBarChart: View {
    let records: [DayRecord]
    let goal: Int

    var body: some View {
        let maxSteps = max(records.map(\.steps).max() ?? 1, goal)

        VStack(spacing: 6) {
            ForEach(records.reversed()) { rec in
                HStack(spacing: 8) {
                    Text(shortDay(rec.dateKey))
                        .font(.ccCaption)
                        .foregroundStyle(CC.textMuted)
                        .frame(width: 30, alignment: .trailing)

                    GeometryReader { geo in
                        let ratio = CGFloat(rec.steps) / CGFloat(maxSteps)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(barColor(steps: rec.steps))
                            .frame(width: geo.size.width * ratio, height: 20)
                    }
                    .frame(height: 20)

                    Text("\(rec.steps)")
                        .font(.ccCaption)
                        .foregroundStyle(CC.textSecondary)
                        .frame(width: 50, alignment: .leading)
                }
            }
        }
    }

    private func barColor(steps: Int) -> LinearGradient {
        if steps >= goal {
            return CC.accentGrad
        } else if steps >= goal / 2 {
            return LinearGradient(colors: [CC.warning, CC.warning.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [CC.danger, CC.danger.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
        }
    }

    private func shortDay(_ key: String) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        guard let date = fmt.date(from: key) else { return key.suffix(2).description }
        let out = DateFormatter()
        out.dateFormat = "EEE"
        return out.string(from: date)
    }
}
