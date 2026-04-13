import SwiftUI
import WebKit

struct WebGateView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        cfg.mediaTypesRequiringUserActionForPlayback = []

        let wv = WKWebView(frame: .zero, configuration: cfg)
        wv.navigationDelegate = context.coordinator
        wv.allowsBackForwardNavigationGestures = true
        wv.scrollView.bounces = true
        wv.isOpaque = false
        wv.backgroundColor = .clear
        wv.scrollView.backgroundColor = .clear
        wv.customUserAgent = WebGate.shared.config.userAgent
        wv.load(URLRequest(url: url))
        return wv
    }

    func updateUIView(_ wv: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ wv: WKWebView, decidePolicyFor action: WKNavigationAction) async -> WKNavigationActionPolicy {
            guard let url = action.request.url else { return .cancel }
            let scheme = url.scheme ?? ""
            if ["tel", "mailto", "itms-apps", "itms-appss"].contains(scheme) {
                await UIApplication.shared.open(url)
                return .cancel
            }
            return .allow
        }

        func webView(_ wv: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            let nsErr = error as NSError
            if nsErr.domain == NSURLErrorDomain, nsErr.code == NSURLErrorCancelled { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                wv.reload()
            }
        }
    }
}
