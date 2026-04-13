import SwiftUI

struct ShopView: View {
    @EnvironmentObject var store: StepStore
    @State private var selectedCategory: MascotCategory?
    @State private var previewMascot: Mascot?

    private var filtered: [Mascot] {
        guard let cat = selectedCategory else { return MascotCatalog.all }
        return MascotCatalog.all.filter { $0.category == cat }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    balanceHeader
                    categoryPicker
                    mascotGrid
                }
                .padding(16)
            }
            .background(CC.bg)
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $previewMascot) { mascot in
                MascotPreviewSheet(mascot: mascot)
                    .environmentObject(store)
            }
        }
    }

    private var balanceHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(CC.coin.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(CC.coin)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(store.progress.totalCoins)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(CC.coin)
                Text("stars available")
                    .font(.system(size: 12))
                    .foregroundStyle(CC.textMuted)
            }

            Spacer()
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(CC.surface))
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryChip(nil, label: "All")
                ForEach(MascotCategory.allCases, id: \.self) { cat in
                    categoryChip(cat, label: cat.label)
                }
            }
        }
    }

    private func categoryChip(_ cat: MascotCategory?, label: String) -> some View {
        let active = selectedCategory == cat
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedCategory = cat }
        } label: {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(active ? .white : CC.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(active ? CC.accent : CC.card)
                )
        }
    }

    private var mascotGrid: some View {
        LazyVGrid(columns: [.init(.flexible(), spacing: 12), .init(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(filtered) { mascot in
                let unlocked = store.progress.unlockedMascotIDs.contains(mascot.id)
                let active = store.progress.activeMascotID == mascot.id

                MascotCard(mascot: mascot, isUnlocked: unlocked, isActive: active)
                    .onTapGesture {
                        if unlocked {
                            store.setActiveMascot(mascot.id)
                        } else {
                            previewMascot = mascot
                        }
                    }
            }
        }
    }
}
