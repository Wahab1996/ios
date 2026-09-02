import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var store: EncounterStore
    @Environment(\.requestNewEncounter) private var requestNewEncounter
    @AppStorage("noteType") private var noteTypeRaw = NoteType.admission.rawValue

    private var noteType: NoteType { NoteType(rawValue: noteTypeRaw) ?? .admission }
    private var tests: [SuggestedTest] { InvestigationEngine.suggestedTests(store: store, noteType: noteType) }

    var body: some View {
        NavigationView {
            Form {
                ForEach(tests) { test in
                    Section {
                        switch test.id {
                        case "cbc": CBCFields(labs: $store.labs)
                        case "renal": RenalFields(labs: $store.labs)
                        case "glucose": LabField(title: "Glucose", value: $store.labs.glucose, unit: "mmol/L")
                        case "crp": LabField(title: "CRP", value: $store.labs.crp, unit: "mg/L")
                        case "lft": LiverFields(labs: $store.labs)
                        case "lipase": LabField(title: "Lipase", value: $store.labs.lipase, unit: "U/L")
                        case "ua": TextField("Urinalysis", text: $store.labs.urinalysis)
                        case "bhcg": TextField("β-hCG", text: $store.labs.pregnancyTest)
                        case "lactate": LabField(title: "Lactate", value: $store.labs.lactate, unit: "mmol/L")
                        case "coag": CoagFields(labs: $store.labs)
                        default: EmptyView()
                        }
                    } header: {
                        HStack { Text(test.title); Spacer(); EvidenceButton(key: test.evidenceKey) }
                    } footer: { Text(test.reason) }
                }
                Section("Imaging") {
                    ForEach(InvestigationEngine.imaging(store: store)) { item in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.title)
                                Text(item.detail).font(.caption).foregroundColor(.secondary)
                            }
                            Spacer(); EvidenceButton(key: item.evidenceKey)
                        }
                    }
                }
                CriticalReviewBanner()
            }
            .navigationTitle("Results")
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("New") { requestNewEncounter() } } }
        }
    }
}

private struct LabField: View {
    let title: String; @Binding var value: String; let unit: String
    var body: some View { HStack { Text(title); Spacer(); TextField("", text: $value).keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 95); Text(unit).font(.caption).foregroundColor(.secondary).frame(minWidth: 55, alignment: .leading) } }
}
private struct CBCFields: View { @Binding var labs: LabResults; var body: some View { Group { LabField(title:"WBC",value:$labs.wbc,unit:"×10⁹/L"); LabField(title:"Hb",value:$labs.hb,unit:"g/dL"); LabField(title:"Platelets",value:$labs.platelets,unit:"×10⁹/L") } } }
private struct RenalFields: View { @Binding var labs: LabResults; var body: some View { Group { LabField(title:"Na",value:$labs.sodium,unit:"mmol/L"); LabField(title:"K",value:$labs.potassium,unit:"mmol/L"); LabField(title:"Urea",value:$labs.urea,unit:"mmol/L"); LabField(title:"Creatinine",value:$labs.creatinine,unit:"µmol/L") } } }
private struct LiverFields: View { @Binding var labs: LabResults; var body: some View { Group { LabField(title:"ALT",value:$labs.alt,unit:"U/L"); LabField(title:"AST",value:$labs.ast,unit:"U/L"); LabField(title:"ALP",value:$labs.alp,unit:"U/L"); LabField(title:"Bilirubin",value:$labs.bilirubin,unit:"µmol/L"); LabField(title:"Albumin",value:$labs.albumin,unit:"g/L") } } }
private struct CoagFields: View { @Binding var labs: LabResults; var body: some View { Group { LabField(title:"INR",value:$labs.inr,unit:""); LabField(title:"aPTT",value:$labs.aptt,unit:"s") } } }
