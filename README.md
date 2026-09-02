# Clinical Note Builder — Native iOS v0.8

A native SwiftUI rewrite of the Abdominal Pain workflow.

## What changed
- Native `TabView`, `NavigationView`, `Form`, `Picker`, `Toggle`, sheets and SF Symbols.
- No WebView / Capacitor UI layer.
- Five tabs only: History, Exam, Results, Note, Settings.
- No explanatory paragraphs in the clinical workflow.
- Progressive disclosure for history source, older/complex patient baseline, recent admission, biliary/urinary/cardiorespiratory context and female/pregnancy context.
- Native medication reconciliation and chronic-condition picker.
- Conditional investigation engine.
- Native evidence sheets.
- Rewritten Saudi Ward note generator.
- Patient encounter stays in memory; settings use `AppStorage`.

## Build unsigned IPA
Upload the project contents to GitHub, then run:
`Actions → Build Native iPhone IPA → Run workflow`.

The artifact is `ClinicalNoteBuilder-Native-IPA`.

Deployment target: iOS 15.0.
Bundle ID: `com.fmclinical.notebuilder`.

If GitHub's browser upload skips the hidden `.github` folder, create `.github/workflows/build-native-ipa.yml` manually and paste the contents of the visible root file `BUILD_NATIVE_IPA.yml`.
