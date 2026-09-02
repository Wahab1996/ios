# Abdominal Pain Medical Specification

Evidence anchors used for v0.8:
- American Family Physician 2023: Acute Abdominal Pain in Adults: Evaluation and Diagnosis.
- ACR Appropriateness Criteria: Right Upper Quadrant Pain (2022), Right Lower Quadrant Pain (2022), Left Lower Quadrant Pain (2023), Acute Nonlocalized Abdominal Pain.
- ACG Clinical Guideline 2024: Management of Acute Pancreatitis.

Core safety behavior:
- Unanswered items are never turned into negative findings.
- Investigation prompts are conditional and are not automatic orders.
- Imaging references are not copied into the clinical note.
- The generator does not infer a diagnosis or management plan.
