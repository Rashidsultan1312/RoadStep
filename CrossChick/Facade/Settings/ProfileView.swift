import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: StepStore
    @AppStorage("userName") private var userName = ""
    @State private var showResetAlert = false

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    avatarSection
                    nameField
                    statsCards
                    settingsSection
                    infoCards
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .background(CC.bg.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Reset Progress?", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) {
                    store.resetAll()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All stars, mascots, and streaks will be lost.")
            }
        }
    }

    private var avatarSection: some View {
        ZStack {
            Circle()
                .fill(CC.card)
                .frame(width: 110, height: 110)

            Image(store.activeMascot.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
                .clipShape(Circle())

            Circle()
                .stroke(CC.accent, lineWidth: 2.5)
                .frame(width: 110, height: 110)
        }
    }

    private var nameField: some View {
        TextField("Your name", text: $userName)
            .font(.ccH2)
            .foregroundStyle(CC.text)
            .multilineTextAlignment(.center)
            .padding(.vertical, 8)
            .tint(CC.accent)
    }

    private var statsCards: some View {
        HStack(spacing: 12) {
            statCard(value: "\(store.progress.totalStepsAllTime)", label: "Total Steps", icon: "figure.walk")
            statCard(value: "\(store.progress.totalCoins)", label: "Stars", icon: "star.circle.fill")
            statCard(value: "\(store.progress.bestStreak)", label: "Best Streak", icon: "flame.fill")
        }
    }

    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(CC.accent)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(CC.text)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(CC.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .ccCard()
    }

    private var settingsSection: some View {
        VStack(spacing: 12) {
            settingsRow(icon: "target", title: "Daily Goal") {
                Picker("", selection: $store.progress.dailyGoal) {
                    Text("3K").tag(3000)
                    Text("5K").tag(5000)
                    Text("7.5K").tag(7500)
                    Text("10K").tag(10000)
                    Text("15K").tag(15000)
                    Text("20K").tag(20000)
                    Text("25K").tag(25000)
                    Text("30K").tag(30000)
                }
                .onChange(of: store.progress.dailyGoal) { _ in store.save() }
            }

            settingsRow(icon: "arrow.left.arrow.right", title: "Steps per Lane") {
                Picker("", selection: $store.progress.stepsPerLane) {
                    Text("500").tag(500)
                    Text("1K").tag(1000)
                    Text("1.5K").tag(1500)
                    Text("2K").tag(2000)
                }
                .onChange(of: store.progress.stepsPerLane) { _ in store.save() }
            }

            settingsRow(icon: "ruler", title: "Units") {
                Picker("", selection: $store.progress.unitSystem) {
                    Text("km").tag(0)
                    Text("mi").tag(1)
                }
                .onChange(of: store.progress.unitSystem) { _ in store.save() }
            }

            settingsRow(icon: "bell.fill", title: "Reminders") {
                Toggle("", isOn: $store.progress.notificationsEnabled)
                    .labelsHidden()
                    .onChange(of: store.progress.notificationsEnabled) { _ in
                        NotificationService.shared.refresh(enabled: store.progress.notificationsEnabled, inactivityMinutes: store.progress.inactivityMinutes)
                        store.save()
                    }
            }

            if store.progress.notificationsEnabled {
                settingsRow(icon: "clock", title: "Morning Alert") {
                    Picker("", selection: $store.progress.morningReminderHour) {
                        Text("6:00").tag(6)
                        Text("7:00").tag(7)
                        Text("8:00").tag(8)
                        Text("9:00").tag(9)
                        Text("Off").tag(0)
                    }
                    .onChange(of: store.progress.morningReminderHour) { _ in
                        NotificationService.shared.scheduleMorningReminder(hour: store.progress.morningReminderHour)
                        store.save()
                    }
                }

                settingsRow(icon: "timer", title: "Inactivity") {
                    Picker("", selection: $store.progress.inactivityMinutes) {
                        Text("15m").tag(15)
                        Text("30m").tag(30)
                        Text("60m").tag(60)
                        Text("Off").tag(0)
                    }
                    .onChange(of: store.progress.inactivityMinutes) { _ in
                        NotificationService.shared.scheduleInactivityAlert(minutes: store.progress.inactivityMinutes)
                        store.save()
                    }
                }
            }
        }
    }

    private func settingsRow<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(CC.accent)
                .frame(width: 24)

            Text(title)
                .font(.ccBody)
                .foregroundStyle(CC.text)

            Spacer()

            content()
                .tint(CC.accent)
        }
        .padding(14)
        .ccCard()
    }

    private var infoCards: some View {
        VStack(spacing: 12) {
            profileRow(icon: "info.circle.fill", title: "Version", value: appVersion)

            Button {
                guard let url = URL(string: "mailto:mykser9204@icloud.com") else { return }
                UIApplication.shared.open(url)
            } label: {
                profileRowContent(icon: "envelope.fill", title: "Support", value: "mykser9204@icloud.com")
            }

            NavigationLink {
                privacyPolicyView
            } label: {
                profileRowContent(icon: "shield.lefthalf.filled", title: "Privacy Policy", value: nil, showChevron: true)
            }

            Button {
                showResetAlert = true
            } label: {
                profileRowContent(icon: "trash.fill", title: "Reset Progress", value: nil, destructive: true)
            }
        }
    }

    private func profileRow(icon: String, title: String, value: String) -> some View {
        profileRowContent(icon: icon, title: title, value: value)
    }

    private func profileRowContent(icon: String, title: String, value: String?, destructive: Bool = false, showChevron: Bool = false) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(destructive ? CC.danger : CC.accent)
                .frame(width: 28)

            Text(title)
                .font(.ccBody)
                .foregroundStyle(destructive ? CC.danger : CC.text)

            Spacer()

            if let value {
                Text(value)
                    .font(.ccCaption)
                    .foregroundStyle(CC.textSecondary)
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(CC.textMuted)
            }
        }
        .padding(16)
        .ccCard()
    }

    private var privacyPolicyView: some View {
        WebGateView(url: URL(string: "https://example.com/privacy")!)
            .ignoresSafeArea()
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
    }
}
