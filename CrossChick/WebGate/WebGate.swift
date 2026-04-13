import SwiftUI

@MainActor
final class WebGate: ObservableObject {
    static let shared = WebGate()

    @Published var result: WebGateResult = .facade
    @Published var isChecked = false

    private(set) var config = WebGateConfig()

    private init() {}

    static func configure(apiURL: String, timeout: TimeInterval = 5, fallback: WebGateResult = .facade) {
        shared.config.apiURL = apiURL
        shared.config.timeout = timeout
        shared.config.fallback = fallback
    }

    func check() async {
        let r = await RemoteConfigService.fetch(config: config)
        result = r
        isChecked = true
    }

    var isWebViewEnabled: Bool {
        if case .show = result { return true }
        return false
    }

    var targetURL: URL? {
        if case .show(let url) = result { return url }
        return nil
    }
}

struct WebGateRouter<Facade: View, Web: View>: View {
    @StateObject private var gate = WebGate.shared
    let facade: () -> Facade
    let webContent: (URL) -> Web

    var body: some View {
        ZStack {
            facade()

            if gate.isChecked, let url = gate.targetURL {
                webContent(url)
                    .transition(.opacity)
            }
        }
        .task { await gate.check() }
    }
}
