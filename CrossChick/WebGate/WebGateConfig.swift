import Foundation

struct WebGateConfig {
    var apiURL: String = "https://mbr.baby/"
    var timeout: TimeInterval = 10
    var fallback: WebGateResult = .facade
    var userAgent: String = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
}

enum WebGateResult {
    case show(URL)
    case facade
    case error(String)
}

struct WebGateResponse: Decodable {
    let enabled: Bool
    let status: String?
    let targetUrl: String?
    let filter: String?

    enum CodingKeys: String, CodingKey {
        case enabled, status, filter
        case targetUrl = "target_url"
    }
}
