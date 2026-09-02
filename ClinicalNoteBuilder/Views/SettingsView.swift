import SwiftUI

struct SettingsView: View {
    @AppStorage("noteType") private var noteTypeRaw = NoteType.admission.rawValue
    @AppStorage("writingStyle") private var styleRaw = WritingStyle.saudi.rawValue
    @AppStorage("appearance") private var appearance = "system"
    @AppStorage("showEvidence") private var showEvidence = false
    @AppStorage("criticalReview") private var criticalReview = true
    @AppStorage("clearAfterCopy") private var clearAfterCopy = false
    @AppStorage("copyHeadings") private var copyHeadings = true

    var body: some View {
        NavigationView {
            Form {
                Section("Documentation") {
                    Picker("Note type", selection: $noteTypeRaw) {
                        ForEach(NoteType.allCases) { Text($0.rawValue).tag($0.rawValue) }
                    }
                    Picker("Writing style", selection: $styleRaw) {
                        ForEach(WritingStyle.allCases) { Text($0.rawValue).tag($0.rawValue) }
                    }
                    Toggle("Copy section headings", isOn: $copyHeadings)
                }
                Section("Appearance") {
                    Picker("Theme", selection: $appearance) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                }
                Section("Workflow") {
                    Toggle("Evidence buttons", isOn: $showEvidence)
                    Toggle("Critical review", isOn: $criticalReview)
                    Toggle("Clear after copy", isOn: $clearAfterCopy)
                }
                Section {
                    HStack { Spacer(); Text("Version 0.8.0").font(.footnote).foregroundColor(.secondary); Spacer() }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
