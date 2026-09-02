import SwiftUI

struct RootTabView: View {
    @EnvironmentObject var store: EncounterStore
    @State private var tab = 0
    @State private var confirmReset = false

    var body: some View {
        TabView(selection: $tab) {
            HistoryView().tabItem { Label("History", systemImage: "list.clipboard") }.tag(0)
            ExamView().tabItem { Label("Exam", systemImage: "stethoscope") }.tag(1)
            ResultsView().tabItem { Label("Results", systemImage: "testtube.2") }.tag(2)
            NoteView().tabItem { Label("Note", systemImage: "doc.text") }.tag(3)
            SettingsView().tabItem { Label("Settings", systemImage: "gearshape") }.tag(4)
        }
        .alert("New patient?", isPresented: $confirmReset) {
            Button("Cancel", role: .cancel) {}
            Button("Clear Encounter", role: .destructive) { store.resetEncounter(); tab = 0 }
        } message: { Text("This clears the current encounter and keeps your settings.") }
        .environment(\.requestNewEncounter, { confirmReset = true })
    }
}

private struct RequestNewEncounterKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var requestNewEncounter: () -> Void {
        get { self[RequestNewEncounterKey.self] }
        set { self[RequestNewEncounterKey.self] = newValue }
    }
}
