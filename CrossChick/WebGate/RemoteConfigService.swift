import Foundation

final class RemoteConfigService {
    private static let session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForResource = 5
        cfg.timeoutIntervalForRequest = 5
        cfg.waitsForConnectivity = false
        return URLSession(configuration: cfg)
    }()

    static func fetch(config: WebGateConfig) async -> WebGateResult {
        guard !config.apiURL.isEmpty, let url = URL(string: config.apiURL) else {
            return config.fallback
        }

        var req = URLRequest(url: url, timeoutInterval: config.timeout)
        req.setValue(config.userAgent, forHTTPHeaderField: "User-Agent")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: req)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                return config.fallback
            }
            let decoded = try JSONDecoder().decode(WebGateResponse.self, from: data)
            if decoded.enabled, let raw = decoded.targetUrl, let target = URL(string: raw) {
                return .show(target)
            }
            return .facade
        } catch {
            return config.fallback
        }
    }
}
