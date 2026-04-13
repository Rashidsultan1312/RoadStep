import SwiftUI

@main
struct CrossChickApp: App {
    init() {
        WebGate.configure(
            apiURL: AppConfig.apiURL,
            timeout: AppConfig.timeout
        )
        setupAppearance()
        NotificationService.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }

    private func setupAppearance() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(CC.bg)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor(CC.text)]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(CC.text)]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(CC.surface)
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}
