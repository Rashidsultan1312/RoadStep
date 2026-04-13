import SwiftUI

struct FacadeTabView: View {
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            RoadView()
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Steps")
                }
                .tag(0)

            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
                .tag(1)

            ShopView()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Shop")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .tint(CC.accent)
    }
}
