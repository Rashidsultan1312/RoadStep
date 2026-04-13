import SwiftUI

enum CC {
    static let bg = Color(hex: 0x1E1E3A)
    static let surface = Color(hex: 0x272750)
    static let card = Color(hex: 0x2D2D4E)
    static let cardElevated = Color(hex: 0x3A3A65)

    static let roadAsphalt = Color(hex: 0x2A2A3F)
    static let laneDash = Color.white.opacity(0.55)
    static let grate = Color(hex: 0x5A5A7A)
    static let grateLight = Color(hex: 0x70708A)

    static let coin = Color(hex: 0xFFD700)
    static let coinDark = Color(hex: 0xDAA520)
    static let accent = Color(hex: 0x4ADE80)
    static let accentDark = Color(hex: 0x22C55E)

    static let danger = Color(hex: 0xEF4444)
    static let warning = Color(hex: 0xFBBF24)

    static let text = Color(hex: 0xF0F0F5)
    static let textSecondary = Color(hex: 0xA0A0C0)
    static let textMuted = Color(hex: 0x606080)

    static let metalLight = Color(hex: 0xC0C0D0)
    static let metalDark = Color(hex: 0x707090)

    static let border = Color(hex: 0x3A3A5E)

    static let radius: CGFloat = 12
    static let radiusSm: CGFloat = 8
    static let radiusLg: CGFloat = 16

    static let roadGrad = LinearGradient(
        colors: [Color(hex: 0x1A1A35), Color(hex: 0x2D2D4E)],
        startPoint: .top, endPoint: .bottom
    )
    static let metalGrad = LinearGradient(
        colors: [metalLight, metalDark],
        startPoint: .top, endPoint: .bottom
    )
    static let coinGrad = LinearGradient(
        colors: [coin, coinDark],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let accentGrad = LinearGradient(
        colors: [accent, accentDark],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

struct CCCardMod: ViewModifier {
    var elevated: Bool = false
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: CC.radius, style: .continuous)
                    .fill(elevated ? CC.cardElevated : CC.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CC.radius, style: .continuous)
                    .stroke(CC.border, lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: CC.radius, style: .continuous))
    }
}

struct CCPrimaryButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(CC.accentGrad)
            .clipShape(RoundedRectangle(cornerRadius: CC.radiusSm))
    }
}

struct CCCoinButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(Color(hex: 0x1A1A00))
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(CC.coinGrad)
            .clipShape(RoundedRectangle(cornerRadius: CC.radiusSm))
    }
}

extension View {
    func ccCard(elevated: Bool = false) -> some View { modifier(CCCardMod(elevated: elevated)) }
    func ccPrimaryButton() -> some View { modifier(CCPrimaryButton()) }
    func ccCoinButton() -> some View { modifier(CCCoinButton()) }
}

extension Font {
    static let ccTitle = Font.system(size: 28, weight: .bold)
    static let ccH2 = Font.system(size: 20, weight: .bold)
    static let ccH3 = Font.system(size: 17, weight: .semibold)
    static let ccBody = Font.system(size: 15)
    static let ccCaption = Font.system(size: 12, weight: .medium)
    static let ccSteps = Font.system(size: 36, weight: .black, design: .rounded)
    static let ccMilestone = Font.system(size: 13, weight: .bold, design: .monospaced)
}
