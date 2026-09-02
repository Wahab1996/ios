import Foundation

final class EncounterStore: ObservableObject {
    @Published var patient = PatientContext()
    @Published var medications: [Medication] = []
    @Published var pain = PainHistory()
    @Published var symptoms = SymptomHistory()
    @Published var relevant = RelevantHistory()
    @Published var female = FemaleContext()
    @Published var exam = ExamFindings()
    @Published var labs = LabResults()
    @Published var admissionLabel = ""

    func resetEncounter() {
        patient = PatientContext()
        medications = []
        pain = PainHistory()
        symptoms = SymptomHistory()
        relevant = RelevantHistory()
        female = FemaleContext()
        exam = ExamFindings()
        labs = LabResults()
        admissionLabel = ""
    }

    var numericAge: Int { Int(patient.age) ?? 0 }

    var showBaseline: Bool {
        numericAge >= 65 || patient.historySource != .patient || patient.conditions.contains("Previous stroke")
    }

    var showBiliaryContext: Bool {
        ["Right upper quadrant", "Epigastric"].contains(pain.location)
    }

    var showUrinaryContext: Bool {
        ["Flank", "Suprapubic", "Lower abdomen / pelvic", "Right lower quadrant", "Left lower quadrant"].contains(pain.location)
    }

    var showCardiorespiratoryContext: Bool {
        numericAge >= 50 || ["Epigastric", "Generalized"].contains(pain.location)
    }

    var criticalMissing: [String] {
        var items: [String] = []
        if patient.age.isEmpty { items.append("Age") }
        if patient.sex == nil { items.append("Sex") }
        if pain.onset.isEmpty { items.append("Pain onset") }
        if pain.duration.isEmpty { items.append("Duration") }
        if pain.location.isEmpty { items.append("Location") }
        if pain.severity.isEmpty { items.append("Severity") }
        if pain.suddenSevere == .unanswered { items.append("Sudden severe onset") }
        if symptoms.vomiting == .unanswered { items.append("Vomiting") }
        if symptoms.fever == .unanswered { items.append("Fever") }
        if symptoms.melena == .unanswered || symptoms.hematochezia == .unanswered { items.append("GI bleeding") }
        if patient.sex == .female && female.pregnancyPossible == .unanswered { items.append("Pregnancy possibility") }
        return items
    }
}
