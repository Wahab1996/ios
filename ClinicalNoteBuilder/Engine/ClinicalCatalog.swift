import Foundation

struct ClinicalCatalog {
    static let conditions = [
        "Hypertension", "Type 2 diabetes mellitus", "Chronic kidney disease", "Ischemic heart disease",
        "Heart failure", "Atrial fibrillation", "Previous stroke", "SLE", "Hypothyroidism",
        "Chronic liver disease", "Peptic ulcer disease", "Gallstones", "Previous pancreatitis",
        "Inflammatory bowel disease", "Malignancy", "Asthma", "COPD", "Epilepsy", "Dyslipidemia",
        "Chronic anemia", "Dementia", "Parkinson disease", "Rheumatoid arthritis", "Other"
    ]

    static let medicationSuggestions = [
        "Amlodipine", "Losartan", "Valsartan", "Lisinopril", "Bisoprolol", "Carvedilol", "Furosemide",
        "Metformin", "Gliclazide", "Sitagliptin", "Empagliflozin", "Dapagliflozin", "Insulin glargine", "Insulin aspart",
        "Aspirin", "Clopidogrel", "Warfarin", "Apixaban", "Rivaroxaban", "Atorvastatin", "Rosuvastatin",
        "Levothyroxine", "Prednisolone", "Hydroxychloroquine", "Mycophenolate mofetil", "Azathioprine", "Tacrolimus",
        "Omeprazole", "Pantoprazole", "Ibuprofen", "Diclofenac", "Naproxen", "Paracetamol", "Tramadol"
    ]

    static let painLocations = [
        "Epigastric", "Right upper quadrant", "Left upper quadrant", "Periumbilical", "Right lower quadrant",
        "Left lower quadrant", "Suprapubic", "Lower abdomen / pelvic", "Generalized", "Flank", "Other"
    ]

    static let painCharacters = ["Cramping / colicky", "Burning", "Sharp", "Dull / aching", "Stabbing", "Pressure", "Tearing", "Other"]
    static let painCourses = ["Constant", "Intermittent", "Progressively worsening", "Improving", "Fluctuating"]

    static let evidence: [String: (title: String, body: String, source: String)] = [
        "acute": ("Acute abdominal pain", "Pain location, onset, temporal course, radiation or migration, and associated symptoms should guide the focused evaluation after confirming clinical stability. Hemodynamic instability, peritoneal findings, or pain out of proportion require urgent escalation.", "American Family Physician 2023"),
        "ruq": ("Right upper quadrant pain", "Ultrasonography is generally preferred as initial imaging when biliary disease is suspected.", "ACR Appropriateness Criteria — RUQ Pain"),
        "rlq": ("Right lower quadrant pain", "In nonpregnant adults, CT abdomen and pelvis with IV contrast is usually appropriate initial imaging when imaging is required.", "ACR Appropriateness Criteria — RLQ Pain"),
        "pregnancy": ("Pregnancy context", "Pregnancy status changes the differential and imaging pathway. Pregnancy testing is relevant when pregnancy is possible and the result would change management.", "American Family Physician 2023"),
        "pancreatitis": ("Pancreatitis pattern", "Compatible epigastric pain with posterior radiation and vomiting supports lipase testing. Routine early CT is not required when acute pancreatitis is otherwise established and there is no diagnostic uncertainty or failure to improve.", "ACG Clinical Guideline 2024"),
        "obstruction": ("Obstruction pattern", "Vomiting, abdominal distension, constipation or obstipation, and previous abdominal surgery increase suspicion for bowel obstruction.", "American Family Physician 2023")
    ]
}
