import Foundation

struct NoteEngine {
    private static func humanList(_ values: [String], conjunction: String = "and") -> String {
        let items = values.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard !items.isEmpty else { return "" }
        if items.count == 1 { return items[0] }
        if items.count == 2 { return "\(items[0]) \(conjunction) \(items[1])" }
        return items.dropLast().joined(separator: ", ") + ", \(conjunction) " + items.last!
    }

    private static func sentence(_ text: String) -> String {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return "" }
        return t.hasSuffix(".") ? t : t + "."
    }

    private static func durationPhrase(_ value: String, unit: String) -> String {
        guard !value.isEmpty else { return "" }
        var cleanUnit = unit.lowercased()
        if cleanUnit.hasSuffix("s") { cleanUnit.removeLast() }
        return "\(value)-\(cleanUnit)"
    }

    static func generate(store: EncounterStore, noteType: NoteType, style: WritingStyle) -> NoteSections {
        let p = store.patient
        let pain = store.pain
        let s = store.symptoms
        let r = store.relevant
        let f = store.female
        let e = store.exam
        let labs = store.labs

        let patientLead: String = {
            if !p.age.isEmpty, let sex = p.sex { return "A \(p.age)-year-old \(sex == .male ? "male" : "female")" }
            if !p.age.isEmpty { return "A \(p.age)-year-old patient" }
            if let sex = p.sex { return "A \(sex == .male ? "male" : "female") patient" }
            return "The patient"
        }()

        var conditionList = Array(p.conditions).filter { $0 != "Other" }.sorted()
        if p.conditions.contains("Other"), !p.otherCondition.isEmpty { conditionList.append(p.otherCondition) }
        let known = conditionList.isEmpty ? "" : ", known case of \(humanList(conditionList)),"
        let duration = durationPhrase(pain.duration, unit: pain.durationUnit)
        var descriptors: [String] = []
        if !pain.onset.isEmpty { descriptors.append("\(pain.onset.lowercased()) in onset") }
        if !pain.location.isEmpty { descriptors.append("mainly localized to the \(pain.location.lowercased())") }
        if !pain.character.isEmpty { descriptors.append("\(pain.character.lowercased()) in character") }
        if !pain.severity.isEmpty { descriptors.append("\(pain.severity)/10 in severity") }
        if !pain.radiation.isEmpty { descriptors.append("radiating to \(pain.radiation)") }
        if !pain.migration.isEmpty { descriptors.append("with migration \(pain.migration)") }
        if !pain.course.isEmpty { descriptors.append(pain.course.lowercased()) }

        var hpi = "\(patientLead)\(known) presented \(noteType == .admission ? "to the Emergency Department " : "")with \(duration.isEmpty ? "" : "a \(duration) history of ")abdominal pain"
        if !descriptors.isEmpty { hpi += ", " + humanList(descriptors) }
        hpi = sentence(hpi)

        var positives: [String] = []
        if s.nausea == .yes { positives.append("nausea") }
        if s.vomiting == .yes { positives.append(s.vomitingDetails.isEmpty ? "vomiting" : "vomiting (\(s.vomitingDetails))") }
        if s.hematemesis == .yes { positives.append("hematemesis") }
        if s.fever == .yes { positives.append("fever/chills") }
        if s.diarrhea == .yes { positives.append("diarrhea") }
        if s.constipation == .yes { positives.append("constipation") }
        if s.obstipation == .yes { positives.append("obstipation") }
        if s.distension == .yes { positives.append("abdominal distension") }
        if s.melena == .yes { positives.append("melena") }
        if s.hematochezia == .yes { positives.append("hematochezia") }
        if s.jaundice == .yes { positives.append("jaundice") }
        if s.dysuria == .yes { positives.append("dysuria") }
        if s.frequency == .yes { positives.append("urinary frequency") }
        if s.hematuria == .yes { positives.append("hematuria") }
        if s.chestPain == .yes { positives.append("chest pain") }
        if s.shortnessOfBreath == .yes { positives.append("shortness of breath") }
        if s.syncope == .yes { positives.append("syncope/presyncope") }
        if !positives.isEmpty { hpi += " It was associated with \(humanList(positives))." }

        let negativePairs: [(TriState, String)] = [
            (s.nausea, "nausea"), (s.vomiting, "vomiting"), (s.hematemesis, "hematemesis"), (s.fever, "fever or chills"),
            (s.diarrhea, "diarrhea"), (s.constipation, "constipation"), (s.obstipation, "obstipation"), (s.distension, "abdominal distension"),
            (s.melena, "melena"), (s.hematochezia, "hematochezia"), (s.jaundice, "jaundice"), (s.dysuria, "dysuria"),
            (s.frequency, "urinary frequency"), (s.hematuria, "hematuria"), (s.chestPain, "chest pain"),
            (s.shortnessOfBreath, "shortness of breath"), (s.syncope, "syncope")
        ]
        let negatives = negativePairs.compactMap { $0.0 == .no ? $0.1 : nil }
        if !negatives.isEmpty { hpi += " There was no history of \(humanList(negatives, conjunction: "or"))." }
        if pain.previous == .yes { hpi += " The patient reported previous similar episodes." }
        if pain.previous == .no { hpi += " No previous similar episodes were reported." }

        var background: [String] = []
        if p.historySource != .patient {
            let source = p.sourceRelation.isEmpty ? p.historySource.rawValue.lowercased() : p.sourceRelation
            var text = "History was obtained mainly from the patient's \(source)"
            if !p.sourceReason.isEmpty { text += " due to \(p.sourceReason)" }
            if p.reliability == .limited { text += "; history was limited" }
            if p.reliability == .poor { text += "; reliability was poor" }
            background.append(sentence(text))
        }
        if !conditionList.isEmpty { background.append("Known medical history includes \(humanList(conditionList)).") }
        if !store.medications.isEmpty {
            let meds = store.medications.compactMap { med -> String? in
                guard !med.name.isEmpty else { return nil }
                return [med.name, med.dose, med.frequency].filter { !$0.isEmpty }.joined(separator: " ")
            }
            if !meds.isEmpty { background.append("Home medications include \(humanList(meds)).") }
            let irregular = store.medications.filter { $0.adherence == "Irregular / missed doses" || $0.adherence == "Stopped" }.map(\.name).filter { !$0.isEmpty }
            if !irregular.isEmpty { background.append("Medication adherence is not regular for \(humanList(irregular)).") }
        }
        if !p.allergies.isEmpty { background.append("Allergies: \(p.allergies).") }
        if p.recentAdmission == .yes {
            let pieces = [p.recentAdmissionWhen.isEmpty ? "" : "discharged \(p.recentAdmissionWhen)", p.recentAdmissionService.isEmpty ? "" : "under \(p.recentAdmissionService)", p.recentAdmissionReason.isEmpty ? "" : "for \(p.recentAdmissionReason)"].filter { !$0.isEmpty }
            background.append(sentence("Recent admission: \(pieces.joined(separator: " "))"))
        }
        if r.abdominalSurgery == .yes { background.append(sentence("Previous abdominal surgery\(r.surgeryDetails.isEmpty ? "" : ": \(r.surgeryDetails)")")) }
        var exposures: [String] = []
        if r.nsaid == .yes { exposures.append("NSAID use") }
        if r.anticoagulant == .yes { exposures.append("anticoagulant use") }
        if r.immunosuppression == .yes { exposures.append("steroid/immunosuppressive therapy") }
        if r.alcohol == .yes { exposures.append("alcohol use") }
        if !exposures.isEmpty { background.append("Relevant history includes \(humanList(exposures)).") }
        if p.sex == .female {
            var gyne: [String] = []
            if !f.lmp.isEmpty { gyne.append("LMP \(f.lmp)") }
            if f.pregnancyPossible == .yes { gyne.append("pregnancy is possible") }
            if f.vaginalBleeding == .yes { gyne.append("vaginal bleeding") }
            if f.pelvicSymptoms == .yes { gyne.append("pelvic symptoms") }
            if !gyne.isEmpty { background.append("Gynecologic history: \(humanList(gyne)).") }
        }

        var examination: [String] = []
        if !e.mentalStatus.isEmpty { examination.append("On examination, the patient was \(e.mentalStatus.lowercased()).") }
        var vitals: [String] = []
        if !e.systolicBP.isEmpty || !e.diastolicBP.isEmpty { vitals.append("BP \(e.systolicBP.isEmpty ? "—" : e.systolicBP)/\(e.diastolicBP.isEmpty ? "—" : e.diastolicBP) mmHg") }
        if !e.heartRate.isEmpty { vitals.append("HR \(e.heartRate) bpm") }
        if !e.respiratoryRate.isEmpty { vitals.append("RR \(e.respiratoryRate)/min") }
        if !e.temperature.isEmpty { vitals.append("temperature \(e.temperature)°C") }
        if !e.oxygenSaturation.isEmpty { vitals.append("SpO₂ \(e.oxygenSaturation)%") }
        if !vitals.isEmpty { examination.append("Vital signs: \(humanList(vitals)).") }

        var abdomenLead: [String] = []
        if !e.abdomen.isEmpty { abdomenLead.append(e.abdomen.lowercased()) }
        if e.distended == .yes { abdomenLead.append("distended") }
        if e.distended == .no { abdomenLead.append("not distended") }
        var abdominalSentence = abdomenLead.isEmpty ? "" : "Abdomen was \(humanList(abdomenLead))"
        if e.tenderness == .yes {
            abdominalSentence += abdominalSentence.isEmpty ? "Abdomen was tender" : ", with tenderness"
            if !e.tendernessLocation.isEmpty { abdominalSentence += " over the \(e.tendernessLocation.lowercased())" }
        } else if e.tenderness == .no {
            abdominalSentence += abdominalSentence.isEmpty ? "Abdomen was non-tender" : " and non-tender"
        }
        var positiveExam: [String] = []
        if e.guarding == .yes { positiveExam.append("guarding") }
        if e.rebound == .yes { positiveExam.append("rebound tenderness") }
        if e.rigidity == .yes { positiveExam.append("rigidity") }
        if e.murphy == .yes { positiveExam.append("positive Murphy sign") }
        if e.cvaTenderness == .yes { positiveExam.append("CVA tenderness") }
        var negativeExam: [String] = []
        if e.guarding == .no { negativeExam.append("guarding") }
        if e.rebound == .no { negativeExam.append("rebound tenderness") }
        if e.rigidity == .no { negativeExam.append("rigidity") }
        if e.murphy == .no { negativeExam.append("Murphy sign") }
        if e.cvaTenderness == .no { negativeExam.append("CVA tenderness") }
        if !abdominalSentence.isEmpty { examination.append(sentence(abdominalSentence)) }
        if !positiveExam.isEmpty { examination.append("Positive abdominal findings included \(humanList(positiveExam)).") }
        if !negativeExam.isEmpty { examination.append("No \(humanList(negativeExam, conjunction: "or")) was elicited.") }
        if !e.other.isEmpty { examination.append(sentence(e.other)) }

        var labPairs: [String] = []
        func add(_ label: String, _ value: String, _ unit: String = "") { if !value.isEmpty { labPairs.append("\(label) \(value)\(unit.isEmpty ? "" : " \(unit)")") } }
        add("WBC", labs.wbc, "×10⁹/L"); add("Hb", labs.hb, "g/dL"); add("platelets", labs.platelets, "×10⁹/L")
        add("Na", labs.sodium, "mmol/L"); add("K", labs.potassium, "mmol/L"); add("urea", labs.urea, "mmol/L"); add("creatinine", labs.creatinine, "µmol/L")
        add("glucose", labs.glucose, "mmol/L"); add("CRP", labs.crp, "mg/L")
        add("ALT", labs.alt, "U/L"); add("AST", labs.ast, "U/L"); add("ALP", labs.alp, "U/L"); add("bilirubin", labs.bilirubin, "µmol/L"); add("albumin", labs.albumin, "g/L")
        add("lipase", labs.lipase, "U/L"); add("lactate", labs.lactate, "mmol/L"); add("INR", labs.inr); add("aPTT", labs.aptt, "s")
        if !labs.pregnancyTest.isEmpty { labPairs.append("β-hCG \(labs.pregnancyTest)") }
        if !labs.urinalysis.isEmpty { labPairs.append("urinalysis \(labs.urinalysis)") }
        let investigationText = labPairs.isEmpty ? "" : "Initial investigations showed \(humanList(labPairs))."
        let admissionText = noteType == .admission && !store.admissionLabel.isEmpty ? "The patient was admitted as a case of \(store.admissionLabel)." : ""

        if style == .concise {
            hpi = hpi.replacingOccurrences(of: "There was no history of", with: "Denied")
        }
        return NoteSections(hpi: hpi, background: background.joined(separator: " "), examination: examination.joined(separator: " "), investigations: investigationText, admission: admissionText)
    }

    static func combined(_ sections: NoteSections, headings: Bool = true) -> String {
        let values: [(String, String)] = [("History of Present Illness", sections.hpi), ("Relevant Background", sections.background), ("Examination", sections.examination), ("Investigations", sections.investigations), ("Admission", sections.admission)]
        return values.filter { !$0.1.isEmpty }.map { headings ? "\($0.0)\n\($0.1)" : $0.1 }.joined(separator: "\n\n")
    }
}
