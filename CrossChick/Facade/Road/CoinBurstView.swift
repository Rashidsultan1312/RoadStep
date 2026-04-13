import SwiftUI

struct CoinBurstView: View {
    @Binding var trigger: Int
    @State private var particles: [CoinParticle] = []

    var body: some View {
        ZStack {
            ForEach(particles) { p in
                Text("🪙")
                    .font(.system(size: 16))
                    .offset(x: p.offsetX, y: p.offsetY)
                    .opacity(p.opacity)
            }
        }
        .onChange(of: trigger) { _ in
            burst()
        }
    }

    private func burst() {
        let newParticles = (0..<8).map { i in
            CoinParticle(
                id: UUID(),
                angle: Double(i) * .pi / 4,
                offsetX: 0, offsetY: 0, opacity: 1
            )
        }
        particles = newParticles

        withAnimation(.easeOut(duration: 0.7)) {
            particles = particles.map { p in
                var q = p
                q.offsetX = cos(p.angle) * 60
                q.offsetY = sin(p.angle) * 60
                q.opacity = 0
                return q
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            particles = []
        }
    }
}

struct CoinParticle: Identifiable {
    let id: UUID
    let angle: Double
    var offsetX: CGFloat
    var offsetY: CGFloat
    var opacity: Double
}
