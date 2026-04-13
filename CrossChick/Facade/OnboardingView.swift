import SwiftUI

struct OnboardingView: View {
    @Binding var completed: Bool
    @State private var page = 0

    private let pages: [(icon: String, title: String, text: String)] = [
        ("figure.walk", "Track Your Steps", "RoadStep counts every step you take and turns your daily walk into a steady routine."),
        ("map", "Cross the Road", "Your mascot walks along a trail as you move. Hit checkpoints, earn stars, and complete daily challenges."),
        ("star.circle.fill", "Collect & Unlock", "Earn stars for reaching goals. Unlock new mascots in the shop and build your streak."),
    ]

    var body: some View {
        ZStack {
            CC.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                TabView(selection: $page) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        pageView(pages[i])
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: page)

                dots
                    .padding(.top, 20)

                Spacer()

                button
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
            }
        }
    }

    private func pageView(_ p: (icon: String, title: String, text: String)) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(CC.accent.opacity(0.12))
                    .frame(width: 120, height: 120)
                Image(systemName: p.icon)
                    .font(.system(size: 44))
                    .foregroundStyle(CC.accent)
            }

            Text(p.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(CC.text)

            Text(p.text)
                .font(.system(size: 15))
                .foregroundStyle(CC.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private var dots: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { i in
                Circle()
                    .fill(i == page ? CC.accent : CC.card)
                    .frame(width: i == page ? 10 : 7, height: i == page ? 10 : 7)
                    .animation(.easeInOut(duration: 0.2), value: page)
            }
        }
    }

    private var button: some View {
        Button {
            if page < pages.count - 1 {
                page += 1
            } else {
                withAnimation { completed = true }
            }
        } label: {
            Text(page < pages.count - 1 ? "Next" : "Get Started")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(CC.accent)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
