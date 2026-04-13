import SwiftUI

struct RoadCanvasView: View {
    let currentLane: Int
    let laneProgress: Double
    let mascotImage: String

    private let laneCount = 10
    private let milestoneCount = 5

    @State private var walkOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let padH: CGFloat = 24
            let usableW = w - padH * 2
            let roadY = h - 56
            let progress: CGFloat = min(1, max(0, (CGFloat(currentLane) + CGFloat(laneProgress)) / CGFloat(laneCount)))

            ZStack {
                // hero mascot — fixed center, walking bounce
                let mascotSize: CGFloat = 160
                Image(mascotImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: mascotSize, height: mascotSize)
                    .shadow(color: CC.accent.opacity(0.55), radius: 22, y: 14)
                    .offset(y: walkOffset)
                    .position(x: w / 2, y: roadY - mascotSize * 0.5 - 18)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                            walkOffset = -3
                        }
                    }

                // soft shadow under mascot's feet (above road)
                Ellipse()
                    .fill(Color.black.opacity(0.35))
                    .frame(width: 80, height: 10)
                    .blur(radius: 6)
                    .position(x: w / 2, y: roadY - 14)

                // road base line
                Path { p in
                    p.move(to: CGPoint(x: padH, y: roadY))
                    p.addLine(to: CGPoint(x: w - padH, y: roadY))
                }
                .stroke(CC.card, style: StrokeStyle(lineWidth: 8, lineCap: .round))

                // road progress fill
                if progress > 0 {
                    Path { p in
                        p.move(to: CGPoint(x: padH, y: roadY))
                        p.addLine(to: CGPoint(x: padH + usableW * progress, y: roadY))
                    }
                    .stroke(CC.accentGrad, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .animation(.easeInOut(duration: 0.4), value: progress)
                }

                // current progress pin under mascot direction
                let pinX = padH + usableW * progress
                Circle()
                    .fill(CC.text)
                    .frame(width: 14, height: 14)
                    .overlay(Circle().stroke(CC.accent, lineWidth: 3))
                    .shadow(color: CC.accent.opacity(0.6), radius: 6)
                    .position(x: min(max(pinX, padH + 7), w - padH - 7), y: roadY)
                    .animation(.easeInOut(duration: 0.4), value: progress)

                // milestone labels under road
                ForEach(0..<milestoneCount, id: \.self) { i in
                    let fraction = CGFloat(i + 1) / CGFloat(milestoneCount)
                    let x = padH + usableW * fraction
                    let done = progress >= fraction - 0.0001
                    let label = "\(2 * (i + 1))K"

                    VStack(spacing: 3) {
                        Circle()
                            .fill(done ? CC.accent : CC.card)
                            .frame(width: 6, height: 6)
                        Text(label)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(done ? CC.accent : CC.textMuted)
                    }
                    .position(x: x, y: roadY + 24)
                    .animation(.easeInOut(duration: 0.3), value: done)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [CC.bg.opacity(0.0), CC.bg.opacity(0.55)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
    }
}
