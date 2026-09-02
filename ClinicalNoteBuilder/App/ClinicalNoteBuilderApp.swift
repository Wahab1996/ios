import SwiftUI

@main
struct ClinicalNoteBuilderApp: App {
    @StateObject private var store = EncounterStore()
    @AppStorage("appearance") private var appearance = "system"

    private var preferredScheme: ColorScheme? {
        switch appearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
                .preferredColorScheme(preferredScheme)
        }
    }
}
