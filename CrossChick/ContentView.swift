import SwiftUI

struct ContentView: View {
    @StateObject private var store = StepStore.shared
    @StateObject private var gate = WebGate.shared
    @AppStorage("onboardingDone") private var onboardingDone = false

    var body: some View {
        ZStack {
            if gate.isChecked, let url = gate.targetURL {
                WebGateView(url: url)
                    .ignoresSafeArea()
            } else if !onboardingDone {
                OnboardingView(completed: $onboardingDone)
            } else {
                FacadeTabView()
                    .environmentObject(store)
                    .task { await store.loadIfNeeded() }
            }
        }
        .task { await gate.check() }
    }
}
