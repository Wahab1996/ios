import Foundation

struct SuggestedTest: Identifiable {
    let id: String
    let title: String
    let reason: String
    let evidenceKey: String
}

struct ImagingReference: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let evidenceKey: String
}

struct InvestigationEngine {
    static func suggestedTests(store: EncounterStore, noteType: NoteType) -> [SuggestedTest] {
        var out: [SuggestedTest] = []
        func add(_ id: String, _ title: String, _ reason: String, _ evidence: String) {
            if !out.contains(where: { $0.id == id }) { out.append(SuggestedTest(id: id, title: title, reason: reason, evidenceKey: evidence)) }
        }
        let s = store.symptoms, p = store.patient, pain = store.pain, r = store.relevant, e = store.exam
        let severe = (Int(pain.severity) ?? 0) >= 7
        let concerning = s.fever == .yes || e.guarding == .yes || e.rebound == .yes || e.rigidity == .yes || pain.suddenSevere == .yes || severe
        if concerning || noteType == .admission {
            add("cbc", "CBC", "Infection, inflammation, anemia or bleeding context", "acute")
            add("renal", "Renal profile", "Electrolytes and renal function", "acute")
            add("glucose", "Glucose", "Metabolic context, diabetes or vomiting", "acute")
        }
        if s.fever == .yes || concerning { add("crp", "CRP", "Inflammatory context", "acute") }
        if ["Right upper quadrant", "Epigastric", "Generalized"].contains(pain.location) || s.jaundice == .yes { add("lft", "Liver profile", "Hepatobiliary context", "ruq") }
        if pain.location == "Epigastric" && (s.vomiting == .yes || pain.radiation.localizedCaseInsensitiveContains("back")) { add("lipase", "Lipase", "Epigastric pain with vomiting or back radiation", "pancreatitis") }
        if store.showUrinaryContext || s.dysuria == .yes || s.hematuria == .yes { add("ua", "Urinalysis", "Urinary tract or stone context", "acute") }
        if p.sex == .female && store.female.pregnancyPossible != .no { add("bhcg", "Pregnancy test", "Pregnancy status may change the diagnostic and imaging pathway", "pregnancy") }
        if pain.suddenSevere == .yes || s.syncope == .yes || (Int(e.systolicBP) ?? 999) < 90 { add("lactate", "Lactate", "Hypoperfusion, ischemia or sepsis context", "acute") }
        if r.anticoagulant == .yes || s.hematemesis == .yes || s.melena == .yes || s.hematochezia == .yes { add("coag", "Coagulation", "Bleeding or anticoagulant context", "acute") }
        return out
    }

    static func imaging(store: EncounterStore) -> [ImagingReference] {
        let loc = store.pain.location
        if loc == "Right upper quadrant" {
            return [ImagingReference(title: "Ultrasound abdomen / RUQ", detail: "Initial imaging when biliary disease is suspected.", evidenceKey: "ruq")]
        }
        if loc == "Right lower quadrant", store.patient.sex != .female {
            return [ImagingReference(title: "CT abdomen/pelvis with IV contrast", detail: "Usually appropriate initial imaging in nonpregnant adults when imaging is required.", evidenceKey: "rlq")]
        }
        if ["Left lower quadrant", "Left upper quadrant", "Generalized"].contains(loc) {
            return [ImagingReference(title: "CT abdomen/pelvis with IV contrast", detail: "Common cross-sectional imaging pathway when clinically indicated.", evidenceKey: "acute")]
        }
        if loc == "Epigastric", store.symptoms.vomiting == .yes {
            return [ImagingReference(title: "Imaging based on the working diagnosis", detail: "Routine early CT is not required for otherwise established acute pancreatitis.", evidenceKey: "pancreatitis")]
        }
        return [ImagingReference(title: "Imaging based on location and clinical suspicion", detail: "No single imaging study is routine for all abdominal pain presentations.", evidenceKey: "acute")]
    }
}
