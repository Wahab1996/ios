import SwiftUI
import UIKit

struct NoteView: View {
    @EnvironmentObject var store: EncounterStore
    @Environment(\.requestNewEncounter) private var requestNewEncounter
    @AppStorage("noteType") private var noteTypeRaw = NoteType.admission.rawValue
    @AppStorage("writingStyle") private var styleRaw = WritingStyle.saudi.rawValue
    @AppStorage("copyHeadings") private var copyHeadings = true
    @AppStorage("clearAfterCopy") private var clearAfterCopy = false
    @State private var copiedMessage = ""

    private var noteType: NoteType { NoteType(rawValue: noteTypeRaw) ?? .admission }
    private var style: WritingStyle { WritingStyle(rawValue: styleRaw) ?? .saudi }
    private var sections: NoteSections { NoteEngine.generate(store: store, noteType: noteType, style: style) }

    var body: some View {
        NavigationView {
            List {
                if noteType == .admission {
                    Section("Admission") {
                        TextField("Admitted as", text: $store.admissionLabel)
                    }
                }
                NoteSection(title: "History of Present Illness", text: sections.hpi)
                if !sections.background.isEmpty { NoteSection(title: "Relevant Background", text: sections.background) }
                if !sections.examination.isEmpty { NoteSection(title: "Examination", text: sections.examination) }
                if !sections.investigations.isEmpty { NoteSection(title: "Investigations", text: sections.investigations) }
                if !sections.admission.isEmpty { NoteSection(title: "Admission", text: sections.admission) }
                Section {
                    HStack(spacing: 10) {
                        Button { copy(sections.hpi, label: "HPI copied") } label: { Label("Copy HPI", systemImage: "doc.on.doc") }.buttonStyle(.bordered).frame(maxWidth: .infinity)
                        Button { copy(NoteEngine.combined(sections, headings: copyHeadings), label: "Note copied", full: true) } label: { Label("Copy Note", systemImage: "square.on.square") }.buttonStyle(.borderedProminent).frame(maxWidth: .infinity)
                    }
                    if !copiedMessage.isEmpty { Text(copiedMessage).font(.caption).foregroundColor(.secondary).frame(maxWidth: .infinity, alignment: .center) }
                }
                CriticalReviewBanner()
            }
            .navigationTitle("Note")
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("New") { requestNewEncounter() } } }
        }
    }

    private func copy(_ text: String, label: String, full: Bool = false) {
        guard !text.isEmpty else { return }
        UIPasteboard.general.string = text
        copiedMessage = label
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copiedMessage = "" }
        if full && clearAfterCopy { DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { store.resetEncounter() } }
    }
}

private struct NoteSection: View {
    let title: String
    let text: String
    var body: some View {
        Section(title) {
            Text(text)
                .textSelection(.enabled)
                .font(.body)
                .lineSpacing(3)
        }
    }
}
