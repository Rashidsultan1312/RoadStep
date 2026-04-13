import SwiftUI

struct MascotPreviewSheet: View {
    let mascot: Mascot
    @EnvironmentObject var store: StepStore
    @Environment(\.dismiss) var dismiss
    @State private var purchased = false

    private var canAfford: Bool { store.progress.totalCoins >= mascot.cost }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(mascot.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .clipShape(Circle())

            Text(mascot.name)
                .font(.ccTitle)
                .foregroundStyle(CC.text)

            Text(mascot.category.label)
                .font(.ccCaption)
                .foregroundStyle(CC.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(CC.card)
                .clipShape(Capsule())

            Spacer()

            if purchased {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(CC.accent)
                    Text("Unlocked!")
                        .font(.ccH2)
                        .foregroundStyle(CC.accent)
                }
            } else {
                VStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(CC.coin)
                        Text("\(mascot.cost)")
                            .font(.ccH2)
                            .foregroundStyle(CC.coin)
                    }

                    Button {
                        if store.unlockMascot(mascot.id) {
                            purchased = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                dismiss()
                            }
                        }
                    } label: {
                        Text(canAfford ? "Unlock" : "Not enough coins")
                            .ccCoinButton()
                    }
                    .disabled(!canAfford)
                    .opacity(canAfford ? 1 : 0.5)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(CC.bg)
        .presentationDetents([.medium])
    }
}
