import Foundation

enum TriState: String, CaseIterable, Identifiable, Codable {
    case unanswered = "—"
    case yes = "Yes"
    case no = "No"
    var id: String { rawValue }
}

enum Sex: String, CaseIterable, Identifiable, Codable {
    case male = "Male"
    case female = "Female"
    var id: String { rawValue }
}

enum HistorySource: String, CaseIterable, Identifiable, Codable {
    case patient = "Patient"
    case relative = "Relative"
    case caregiver = "Caregiver"
    case records = "Records"
    case mixed = "Mixed"
    var id: String { rawValue }
}

enum HistoryReliability: String, CaseIterable, Identifiable, Codable {
    case good = "Good"
    case limited = "Limited"
    case poor = "Poor"
    var id: String { rawValue }
}

enum NoteType: String, CaseIterable, Identifiable {
    case admission = "Admission"
    case clinic = "Clinic"
    var id: String { rawValue }
}

enum WritingStyle: String, CaseIterable, Identifiable {
    case saudi = "Saudi Ward"
    case concise = "Concise"
    case formal = "Formal"
    var id: String { rawValue }
}

struct Medication: Identifiable, Codable, Equatable {
    var id = UUID()
    var name = ""
    var dose = ""
    var frequency = ""
    var adherence = "Unknown"
}

struct PatientContext {
    var age = ""
    var sex: Sex? = nil
    var historySource: HistorySource = .patient
    var sourceRelation = ""
    var sourceReason = ""
    var reliability: HistoryReliability = .good
    var conditions: Set<String> = []
    var otherCondition = ""
    var allergies = ""
    var recentAdmission: TriState = .unanswered
    var recentAdmissionWhen = ""
    var recentAdmissionService = ""
    var recentAdmissionReason = ""
    var baselineFunction = "Independent"
}

struct PainHistory {
    var onset = ""
    var duration = ""
    var durationUnit = "days"
    var location = ""
    var severity = ""
    var character = ""
    var course = ""
    var radiation = ""
    var migration = ""
    var previous: TriState = .unanswered
    var suddenSevere: TriState = .unanswered
}

struct SymptomHistory {
    var nausea: TriState = .unanswered
    var vomiting: TriState = .unanswered
    var vomitingDetails = ""
    var hematemesis: TriState = .unanswered
    var fever: TriState = .unanswered
    var diarrhea: TriState = .unanswered
    var constipation: TriState = .unanswered
    var obstipation: TriState = .unanswered
    var distension: TriState = .unanswered
    var melena: TriState = .unanswered
    var hematochezia: TriState = .unanswered
    var jaundice: TriState = .unanswered
    var dysuria: TriState = .unanswered
    var frequency: TriState = .unanswered
    var hematuria: TriState = .unanswered
    var chestPain: TriState = .unanswered
    var shortnessOfBreath: TriState = .unanswered
    var syncope: TriState = .unanswered
}

struct RelevantHistory {
    var abdominalSurgery: TriState = .unanswered
    var surgeryDetails = ""
    var nsaid: TriState = .unanswered
    var anticoagulant: TriState = .unanswered
    var immunosuppression: TriState = .unanswered
    var alcohol: TriState = .unanswered
    var knownGallstones: TriState = .unanswered
    var knownRenalStones: TriState = .unanswered
}

struct FemaleContext {
    var pregnancyPossible: TriState = .unanswered
    var lmp = ""
    var vaginalBleeding: TriState = .unanswered
    var pelvicSymptoms: TriState = .unanswered
}

struct ExamFindings {
    var mentalStatus = ""
    var distress: TriState = .unanswered
    var dehydration: TriState = .unanswered
    var systolicBP = ""
    var diastolicBP = ""
    var heartRate = ""
    var respiratoryRate = ""
    var temperature = ""
    var oxygenSaturation = ""
    var abdomen = ""
    var distended: TriState = .unanswered
    var tenderness: TriState = .unanswered
    var tendernessLocation = ""
    var guarding: TriState = .unanswered
    var rebound: TriState = .unanswered
    var rigidity: TriState = .unanswered
    var murphy: TriState = .unanswered
    var cvaTenderness: TriState = .unanswered
    var other = ""
}

struct LabResults {
    var wbc = ""; var hb = ""; var platelets = ""
    var sodium = ""; var potassium = ""; var urea = ""; var creatinine = ""
    var glucose = ""; var crp = ""
    var alt = ""; var ast = ""; var alp = ""; var bilirubin = ""; var albumin = ""
    var lipase = ""; var lactate = ""; var inr = ""; var aptt = ""
    var pregnancyTest = ""; var urinalysis = ""
}

struct NoteSections {
    var hpi = ""
    var background = ""
    var examination = ""
    var investigations = ""
    var admission = ""
}
