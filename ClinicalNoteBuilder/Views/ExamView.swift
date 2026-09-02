import SwiftUI

struct ExamView: View {
    @EnvironmentObject var store: EncounterStore
    @Environment(\.requestNewEncounter) private var requestNewEncounter

    var body: some View {
        NavigationView {
            Form {
                Section("Vitals") {
                    HStack {
                        Text("BP")
                        Spacer()
                        TextField("120", text: $store.exam.systolicBP).keyboardType(.numberPad).multilineTextAlignment(.trailing).frame(width: 55)
                        Text("/").foregroundColor(.secondary)
                        TextField("80", text: $store.exam.diastolicBP).keyboardType(.numberPad).frame(width: 55)
                        Text("mmHg").font(.caption).foregroundColor(.secondary)
                    }
                    NumberUnitRow(title: "HR", value: $store.exam.heartRate, unit: "bpm")
                    NumberUnitRow(title: "RR", value: $store.exam.respiratoryRate, unit: "/min")
                    NumberUnitRow(title: "Temperature", value: $store.exam.temperature, unit: "°C", decimal: true)
                    NumberUnitRow(title: "SpO₂", value: $store.exam.oxygenSaturation, unit: "%")
                }
                Section("General") {
                    Picker("Mental status", selection: $store.exam.mentalStatus) {
                        Text("Not documented").tag("")
                        Text("Conscious, alert and oriented").tag("Conscious, alert and oriented")
                        Text("Drowsy but arousable").tag("Drowsy but arousable")
                        Text("Confused").tag("Confused")
                        Text("Unresponsive").tag("Unresponsive")
                    }
                    TriStatePicker(title: "Appears distressed", value: $store.exam.distress)
                    TriStatePicker(title: "Clinical dehydration", value: $store.exam.dehydration)
                }
                Section("Abdomen") {
                    Picker("Abdomen", selection: $store.exam.abdomen) {
                        Text("Not documented").tag("")
                        Text("Soft").tag("Soft")
                        Text("Tense").tag("Tense")
                    }
                    TriStatePicker(title: "Distension", value: $store.exam.distended)
                    TriStatePicker(title: "Tenderness", value: $store.exam.tenderness)
                    if store.exam.tenderness == .yes { TextField("Tenderness location", text: $store.exam.tendernessLocation) }
                    TriStatePicker(title: "Guarding", value: $store.exam.guarding)
                    TriStatePicker(title: "Rebound tenderness", value: $store.exam.rebound)
                    TriStatePicker(title: "Rigidity", value: $store.exam.rigidity)
                    if store.pain.location == "Right upper quadrant" { TriStatePicker(title: "Murphy sign", value: $store.exam.murphy) }
                    if store.showUrinaryContext { TriStatePicker(title: "CVA tenderness", value: $store.exam.cvaTenderness) }
                    TextField("Other examination", text: $store.exam.other)
                }
                CriticalReviewBanner()
            }
            .navigationTitle("Examination")
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("New") { requestNewEncounter() } } }
        }
    }
}

private struct NumberUnitRow: View {
    let title: String
    @Binding var value: String
    let unit: String
    var decimal = false
    var body: some View {
        HStack {
            Text(title); Spacer()
            TextField("", text: $value).keyboardType(decimal ? .decimalPad : .numberPad).multilineTextAlignment(.trailing).frame(width: 90)
            Text(unit).font(.caption).foregroundColor(.secondary).frame(minWidth: 42, alignment: .leading)
        }
    }
}
