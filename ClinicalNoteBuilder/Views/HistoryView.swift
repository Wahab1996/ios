import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: EncounterStore
    @Environment(\.requestNewEncounter) private var requestNewEncounter
    @State private var showConditions = false
    @State private var medicationToEdit: Medication?
    @State private var addingMedication = false

    var body: some View {
        NavigationView {
            Form {
                patientSection
                backgroundSection
                painSection
                associatedSection
                conditionalAssociatedSections
                relevantSection
                CriticalReviewBanner()
            }
            .navigationTitle("Abdominal Pain")
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("New") { requestNewEncounter() } } }
            .sheet(isPresented: $showConditions) { ConditionPickerView(selected: $store.patient.conditions) }
            .sheet(isPresented: $addingMedication) {
                MedicationEditorView(existing: nil) { med in store.medications.append(med) }
            }
            .sheet(item: $medicationToEdit) { med in
                MedicationEditorView(existing: med, onSave: { edited in
                    if let idx = store.medications.firstIndex(where: { $0.id == med.id }) {
                        var replacement = edited; replacement.id = med.id; store.medications[idx] = replacement
                    }
                }, onDelete: {
                    store.medications.removeAll { $0.id == med.id }
                })
            }
        }
    }

    private var patientSection: some View {
        Section("Patient") {
            TextField("Age", text: $store.patient.age).keyboardType(.numberPad)
            Picker("Sex", selection: $store.patient.sex) {
                Text("Select").tag(Sex?.none)
                Text("Male").tag(Sex?.some(.male))
                Text("Female").tag(Sex?.some(.female))
            }
            Picker("History from", selection: $store.patient.historySource) {
                ForEach(HistorySource.allCases) { Text($0.rawValue).tag($0) }
            }
            if store.patient.historySource != .patient {
                TextField("Relation / source", text: $store.patient.sourceRelation)
                TextField("Reason", text: $store.patient.sourceReason)
                Picker("Reliability", selection: $store.patient.reliability) {
                    ForEach(HistoryReliability.allCases) { Text($0.rawValue).tag($0) }
                }
            }
        }
    }

    private var backgroundSection: some View {
        Section("Background") {
            Button {
                showConditions = true
            } label: {
                HStack {
                    Text("Medical history").foregroundColor(.primary)
                    Spacer()
                    Text(store.patient.conditions.isEmpty ? "Add" : "\(store.patient.conditions.count) selected").foregroundColor(.secondary)
                    Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
                }
            }
            if store.patient.conditions.contains("Other") {
                TextField("Other condition", text: $store.patient.otherCondition)
            }
            if store.showBaseline {
                Picker("Baseline function", selection: $store.patient.baselineFunction) {
                    ForEach(["Independent", "Needs assistance", "Wheelchair", "Bedridden", "Unknown"], id: \.self) { Text($0).tag($0) }
                }
            }
            ForEach(store.medications) { med in
                Button { medicationToEdit = med } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(med.name).foregroundColor(.primary)
                            Text([med.dose, med.frequency, med.adherence].filter { !$0.isEmpty }.joined(separator: " · ")).font(.caption).foregroundColor(.secondary)
                        }
                        Spacer(); Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            Button { addingMedication = true } label: { Label("Add medication", systemImage: "plus") }
            TextField("Allergies", text: $store.patient.allergies)
            TriStatePicker(title: "Recent admission (<30 days)", value: $store.patient.recentAdmission)
            if store.patient.recentAdmission == .yes {
                TextField("When", text: $store.patient.recentAdmissionWhen)
                TextField("Service", text: $store.patient.recentAdmissionService)
                TextField("Reason", text: $store.patient.recentAdmissionReason)
            }
        }
    }

    private var painSection: some View {
        Section("Pain") {
            Picker("Onset", selection: $store.pain.onset) {
                Text("Select").tag(""); Text("Sudden").tag("Sudden"); Text("Gradual").tag("Gradual"); Text("Unclear").tag("Unclear")
            }
            HStack {
                Text("Duration")
                Spacer()
                TextField("2", text: $store.pain.duration).keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 60)
                Picker("", selection: $store.pain.durationUnit) { ForEach(["hours","days","weeks","months"], id: \.self) { Text($0.capitalized).tag($0) } }.labelsHidden().frame(width: 115)
            }
            Picker("Location", selection: $store.pain.location) { Text("Select").tag(""); ForEach(ClinicalCatalog.painLocations, id: \.self) { Text($0).tag($0) } }
            HStack { Text("Severity"); Spacer(); TextField("0–10", text: $store.pain.severity).keyboardType(.numberPad).multilineTextAlignment(.trailing).frame(width: 80) }
            Picker("Character", selection: $store.pain.character) { Text("Select").tag(""); ForEach(ClinicalCatalog.painCharacters, id: \.self) { Text($0).tag($0) } }
            Picker("Course", selection: $store.pain.course) { Text("Select").tag(""); ForEach(ClinicalCatalog.painCourses, id: \.self) { Text($0).tag($0) } }
            TextField("Radiation", text: $store.pain.radiation)
            TextField("Migration", text: $store.pain.migration)
            TriStatePicker(title: "Previous similar pain", value: $store.pain.previous)
            TriStatePicker(title: "Sudden / excruciating", value: $store.pain.suddenSevere)
        }
    }

    private var associatedSection: some View {
        Section("Associated") {
            TriStatePicker(title: "Nausea", value: $store.symptoms.nausea)
            TriStatePicker(title: "Vomiting", value: $store.symptoms.vomiting)
            if store.symptoms.vomiting == .yes { TextField("Vomiting details", text: $store.symptoms.vomitingDetails) }
            TriStatePicker(title: "Fever / chills", value: $store.symptoms.fever)
            TriStatePicker(title: "Diarrhea", value: $store.symptoms.diarrhea)
            TriStatePicker(title: "Constipation", value: $store.symptoms.constipation)
            TriStatePicker(title: "Unable to pass stool / flatus", value: $store.symptoms.obstipation)
            TriStatePicker(title: "Abdominal distension", value: $store.symptoms.distension)
            TriStatePicker(title: "Hematemesis", value: $store.symptoms.hematemesis)
            TriStatePicker(title: "Melena", value: $store.symptoms.melena)
            TriStatePicker(title: "Hematochezia", value: $store.symptoms.hematochezia)
        }
    }

    @ViewBuilder private var conditionalAssociatedSections: some View {
        if store.showBiliaryContext {
            Section("Biliary") { TriStatePicker(title: "Jaundice", value: $store.symptoms.jaundice) }
        }
        if store.showUrinaryContext {
            Section("Urinary") {
                TriStatePicker(title: "Dysuria", value: $store.symptoms.dysuria)
                TriStatePicker(title: "Frequency", value: $store.symptoms.frequency)
                TriStatePicker(title: "Hematuria", value: $store.symptoms.hematuria)
            }
        }
        if store.showCardiorespiratoryContext {
            Section("Cardiorespiratory") {
                TriStatePicker(title: "Chest pain", value: $store.symptoms.chestPain)
                TriStatePicker(title: "Shortness of breath", value: $store.symptoms.shortnessOfBreath)
                TriStatePicker(title: "Syncope / presyncope", value: $store.symptoms.syncope)
            }
        }
    }

    private var relevantSection: some View {
        Section("Relevant") {
            TriStatePicker(title: "Previous abdominal surgery", value: $store.relevant.abdominalSurgery)
            if store.relevant.abdominalSurgery == .yes { TextField("Surgery details", text: $store.relevant.surgeryDetails) }
            TriStatePicker(title: "NSAID use", value: $store.relevant.nsaid)
            TriStatePicker(title: "Anticoagulant use", value: $store.relevant.anticoagulant)
            TriStatePicker(title: "Steroid / immunosuppression", value: $store.relevant.immunosuppression)
            TriStatePicker(title: "Alcohol use", value: $store.relevant.alcohol)
            if store.showBiliaryContext { TriStatePicker(title: "Known gallstones", value: $store.relevant.knownGallstones) }
            if store.showUrinaryContext { TriStatePicker(title: "Known renal stones", value: $store.relevant.knownRenalStones) }
            if store.patient.sex == .female {
                TriStatePicker(title: "Pregnancy possible", value: $store.female.pregnancyPossible)
                TextField("LMP", text: $store.female.lmp)
                TriStatePicker(title: "Vaginal bleeding", value: $store.female.vaginalBleeding)
                TriStatePicker(title: "Pelvic symptoms", value: $store.female.pelvicSymptoms)
            }
        }
    }
}
