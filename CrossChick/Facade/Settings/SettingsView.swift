import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: StepStore
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Daily Goal", selection: $store.progress.dailyGoal) {
                        Text("3,000").tag(3000)
                        Text("5,000").tag(5000)
                        Text("7,500").tag(7500)
                        Text("10,000").tag(10000)
                        Text("12,500").tag(12500)
                        Text("15,000").tag(15000)
                        Text("20,000").tag(20000)
                        Text("25,000").tag(25000)
                        Text("30,000").tag(30000)
                    }
                    .onChange(of: store.progress.dailyGoal) { _ in store.save() }

                    Picker("Weekly Goal", selection: $store.progress.weeklyGoal) {
                        Text("20,000").tag(20000)
                        Text("35,000").tag(35000)
                        Text("50,000").tag(50000)
                        Text("70,000").tag(70000)
                        Text("100,000").tag(100000)
                    }
                    .onChange(of: store.progress.weeklyGoal) { _ in store.save() }

                    Picker("Steps per Lane", selection: $store.progress.stepsPerLane) {
                        Text("500").tag(500)
                        Text("1,000").tag(1000)
                        Text("1,500").tag(1500)
                        Text("2,000").tag(2000)
                        Text("2,500").tag(2500)
                    }
                    .onChange(of: store.progress.stepsPerLane) { _ in store.save() }
                } header: {
                    Text("Goals")
                }

                Section {
                    Picker("Units", selection: $store.progress.unitSystem) {
                        Text("Metric (km)").tag(0)
                        Text("Imperial (mi)").tag(1)
                    }
                    .onChange(of: store.progress.unitSystem) { _ in store.save() }
                } header: {
                    Text("Units")
                }

                Section {
                    Toggle("Reminders", isOn: $store.progress.notificationsEnabled)
                        .onChange(of: store.progress.notificationsEnabled) { _ in
                            NotificationService.shared.refresh(enabled: store.progress.notificationsEnabled, inactivityMinutes: store.progress.inactivityMinutes)
                            store.save()
                        }

                    if store.progress.notificationsEnabled {
                        Picker("Morning Reminder", selection: $store.progress.morningReminderHour) {
                            Text("6:00").tag(6)
                            Text("7:00").tag(7)
                            Text("8:00").tag(8)
                            Text("9:00").tag(9)
                            Text("10:00").tag(10)
                            Text("Off").tag(0)
                        }
                        .onChange(of: store.progress.morningReminderHour) { _ in
                            NotificationService.shared.scheduleMorningReminder()
                            store.save()
                        }

                        Picker("Inactivity Alert", selection: $store.progress.inactivityMinutes) {
                            Text("15 min").tag(15)
                            Text("30 min").tag(30)
                            Text("45 min").tag(45)
                            Text("60 min").tag(60)
                            Text("90 min").tag(90)
                            Text("Off").tag(0)
                        }
                        .onChange(of: store.progress.inactivityMinutes) { _ in
                            NotificationService.shared.scheduleInactivityAlert(minutes: store.progress.inactivityMinutes)
                            store.save()
                        }
                    }
                } header: {
                    Text("Notifications")
                }

                Section {
                    Toggle("Haptic Feedback", isOn: $store.progress.hapticEnabled)
                        .onChange(of: store.progress.hapticEnabled) { _ in store.save() }
                } header: {
                    Text("General")
                }

                Section {
                    Button("Reset Progress", role: .destructive) {
                        showResetAlert = true
                    }
                } header: {
                    Text("Account")
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(CC.textMuted)
                    }
                } header: {
                    Text("About")
                }
            }
            .scrollContentBackground(.hidden)
            .background(CC.bg)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Reset Progress?", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) {
                    store.resetAll()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All coins, mascots, and streaks will be lost.")
            }
        }
    }
}
