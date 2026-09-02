import SwiftUI

struct TriStatePicker: View {
    let title: String
    @Binding var value: TriState

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Picker("", selection: $value) {
                ForEach(TriState.allCases) { item in Text(item.rawValue).tag(item) }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 190)
        }
    }
}

struct CriticalReviewBanner: View {
    @EnvironmentObject var store: EncounterStore
    @AppStorage("criticalReview") private var criticalReview = true

    var body: some View {
        if criticalReview, !store.criticalMissing.isEmpty {
            Section {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "exclamationmark.circle.fill").foregroundColor(.orange)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(store.criticalMissing.count) item\(store.criticalMissing.count == 1 ? "" : "s") not documented").font(.subheadline.weight(.semibold))
                        Text(store.criticalMissing.prefix(5).joined(separator: " · ")).font(.caption).foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct EvidenceButton: View {
    let key: String
    @AppStorage("showEvidence") private var showEvidence = false
    @State private var showing = false

    var body: some View {
        if showEvidence {
            Button { showing = true } label: { Image(systemName: "info.circle") }
                .buttonStyle(.plain)
                .sheet(isPresented: $showing) { EvidenceSheet(key: key) }
        }
    }
}

struct EvidenceSheet: View {
    let key: String
    @Environment(\.dismiss) private var dismiss
    var item: (title: String, body: String, source: String) { ClinicalCatalog.evidence[key] ?? ClinicalCatalog.evidence["acute"]! }

    var body: some View {
        NavigationView {
            List {
                Section { Text(item.body) }
                Section("Source") { Text(item.source).foregroundColor(.secondary) }
            }
            .navigationTitle(item.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
}

struct ConditionPickerView: View {
    @Binding var selected: Set<String>
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""

    private var filtered: [String] {
        if search.isEmpty { return ClinicalCatalog.conditions }
        return ClinicalCatalog.conditions.filter { $0.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        NavigationView {
            List(filtered, id: \.self) { condition in
                Button {
                    if selected.contains(condition) { selected.remove(condition) } else { selected.insert(condition) }
                } label: {
                    HStack {
                        Text(condition).foregroundColor(.primary)
                        Spacer()
                        if selected.contains(condition) { Image(systemName: "checkmark").foregroundColor(.accentColor) }
                    }
                }
            }
            .searchable(text: $search)
            .navigationTitle("Medical History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
}

struct MedicationEditorView: View {
    var existing: Medication?
    var onSave: (Medication) -> Void
    var onDelete: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var medication = Medication()

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Medication", text: $medication.name)
                    TextField("Dose", text: $medication.dose)
                    TextField("Frequency", text: $medication.frequency)
                    Picker("Adherence", selection: $medication.adherence) {
                        Text("Unknown").tag("Unknown")
                        Text("Regular").tag("Regular")
                        Text("Irregular / missed doses").tag("Irregular / missed doses")
                        Text("Stopped").tag("Stopped")
                    }
                }
                Section("Common") {
                    ForEach(ClinicalCatalog.medicationSuggestions.prefix(12), id: \.self) { item in
                        Button(item) { medication.name = item }.foregroundColor(.primary)
                    }
                }
                if let onDelete {
                    Section { Button("Delete Medication", role: .destructive) { onDelete(); dismiss() } }
                }
            }
            .navigationTitle(existing == nil ? "Add Medication" : "Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { onSave(medication); dismiss() }.disabled(medication.name.trimmingCharacters(in: .whitespaces).isEmpty) }
            }
            .onAppear { if let existing { medication = existing } }
        }
    }
}
