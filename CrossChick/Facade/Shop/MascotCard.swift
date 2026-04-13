import SwiftUI

struct MascotCard: View {
    let mascot: Mascot
    let isUnlocked: Bool
    let isActive: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isActive ? CC.accent.opacity(0.2) : CC.cardElevated)
                    .frame(width: 80, height: 80)

                if isUnlocked {
                    Image(mascot.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                } else {
                    Image(mascot.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                        .saturation(0)
                        .opacity(0.4)
                }

                if isActive {
                    Circle()
                        .stroke(CC.accent, lineWidth: 2)
                        .frame(width: 84, height: 84)
                }
            }

            Text(mascot.name)
                .font(.ccH3)
                .foregroundStyle(isUnlocked ? CC.text : CC.textMuted)

            if isUnlocked {
                if isActive {
                    Text("Active")
                        .font(.ccCaption)
                        .foregroundStyle(CC.accent)
                } else {
                    Text("Tap to select")
                        .font(.ccCaption)
                        .foregroundStyle(CC.textSecondary)
                }
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(CC.coin)
                    Text("\(mascot.cost)")
                        .font(.ccCaption)
                        .foregroundStyle(CC.coin)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .ccCard()
    }
}
