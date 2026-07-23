import SwiftData
import SwiftUI

enum NotesSegment: String, CaseIterable, Identifiable {
    case notes = "Notes"
    case favorites = "Favorites"
    case seen = "Seen"

    var id: String { rawValue }
}

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var contentStore: AppContentStore
    @Query(sort: \ReadingNote.updatedAt, order: .reverse) private var notes: [ReadingNote]
    @Query private var favorites: [FavoriteRecord]
    @Query private var seenRecords: [SeenRecord]
    @State private var segment: NotesSegment = .notes
    @State private var showingNoteEditor = false

    var body: some View {
        List {
            Section {
                Picker("Notes section", selection: $segment) {
                    ForEach(NotesSegment.allCases) { segment in
                        Text(segment.rawValue).tag(segment)
                    }
                }
                .pickerStyle(.segmented)
            }

            switch segment {
            case .notes:
                notesSection
            case .favorites:
                favoritesSection
            case .seen:
                seenSection
            }
        }
        .navigationTitle(String(localized: "tab.notes"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingNoteEditor = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add note")
                .accessibilityIdentifier(A11yID.addNoteButton)
            }
        }
        .sheet(isPresented: $showingNoteEditor) {
            NoteEditorView(linkedKind: .topic, linkedID: "topic-archives", suggestedTitle: "Research note")
        }
        .accessibilityIdentifier(A11yID.notesView)
    }

    @ViewBuilder
    private var notesSection: some View {
        if notes.isEmpty {
            ContentUnavailableView("No notes yet", systemImage: "note.text", description: Text("Notes you add on any work appear here."))
        } else {
            Section("Notes") {
                ForEach(notes) { note in
                    VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                        Text(note.title)
                            .font(.headline)
                        Text(note.body)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            modelContext.delete(note)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .accessibilityIdentifier("note.row.\(note.id)")
                }
            }
        }
    }

    private var favoritesSection: some View {
        Section("Favorites") {
            if favorites.isEmpty {
                ContentUnavailableView("No favorites", systemImage: "heart", description: Text("Favorite works to find them here."))
            } else {
                ForEach(favorites) { favorite in
                    if let work = contentStore.content.work(id: favorite.linkedID) {
                        WorkRow(work: work)
                    }
                }
            }
        }
    }

    private var seenSection: some View {
        Section("Seen") {
            if seenRecords.isEmpty {
                ContentUnavailableView("Nothing marked seen", systemImage: "checkmark.circle", description: Text("Mark works as seen from their detail page."))
            } else {
                ForEach(seenRecords) { seen in
                    if let work = contentStore.content.work(id: seen.workID) {
                        WorkRow(work: work)
                    }
                }
            }
        }
    }
}

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    var linkedKind: UserLinkedKind
    var linkedID: String
    var suggestedTitle: String
    @State private var title: String
    @State private var bodyText = ""

    init(linkedKind: UserLinkedKind, linkedID: String, suggestedTitle: String) {
        self.linkedKind = linkedKind
        self.linkedID = linkedID
        self.suggestedTitle = suggestedTitle
        _title = State(initialValue: suggestedTitle)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Title", text: $title)
                        .accessibilityIdentifier("note.titleField")
                }
                Section("Note") {
                    TextEditor(text: $bodyText)
                        .frame(minHeight: 160)
                        .accessibilityIdentifier("note.bodyField")
                }
            }
            .navigationTitle("New note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        modelContext.insert(ReadingNote(linkedKind: linkedKind, linkedID: linkedID, title: title, body: bodyText))
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier(A11yID.saveNoteButton)
                }
            }
            .accessibilityIdentifier(A11yID.noteEditorView)
        }
    }
}
