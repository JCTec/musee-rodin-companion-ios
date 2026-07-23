import SwiftData
import SwiftUI

struct WorkDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var contentStore: AppContentStore
    @EnvironmentObject private var narrator: NarrationController
    @Query private var favorites: [FavoriteRecord]
    @Query private var seenRecords: [SeenRecord]
    @State private var showingNoteEditor = false

    var work: Work

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.large) {
                WorkArtworkImage(work: work, style: .hero)

                VStack(alignment: .leading, spacing: Spacing.small) {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading) {
                            Text(work.title.value(for: contentStore.language))
                                .font(.title.bold())
                            Text("\(work.artist) - \(work.dateText)")
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        ConfidenceChip(confidence: work.confidence)
                    }

                    MetadataGrid(items: [
                        ("Material", work.material.value(for: contentStore.language)),
                        ("Date", work.dateText),
                        ("Inventory", work.inventoryNumber ?? "source needed"),
                        ("Location", work.locationStatus.value(for: contentStore.language))
                    ])
                    .appCard()

                    if let stop = contentStore.content.audioStops.first(where: { $0.linkedID == work.id }) {
                        ReadAloudButton(stop: stop)
                    }

                    Text("About")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(work.summary.value(for: contentStore.language))
                        .font(.body)

                    DisclosureGroup("Research note") {
                        Text(work.researchNote.value(for: contentStore.language))
                            .font(.body)
                            .padding(.vertical, Spacing.xSmall)
                    }
                    .appCard()

                    DisclosureGroup("Sources") {
                        FlowLayout(spacing: Spacing.xSmall) {
                            ForEach(work.citations) { citation in
                                CitationChip(citation: citation)
                            }
                        }
                        .padding(.top, Spacing.xSmall)
                    }
                    .appCard()

                    FlowLayout(spacing: Spacing.xSmall) {
                        ForEach(work.tags, id: \.self) { tag in
                            TagChip(title: tag)
                        }
                    }

                    actionBar
                }
                .padding(Spacing.medium)
            }
        }
        .background(AppColor.background)
        .navigationTitle(work.title.value(for: contentStore.language))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingNoteEditor) {
            NoteEditorView(linkedKind: .work, linkedID: work.id, suggestedTitle: work.title.value(for: contentStore.language))
        }
        .accessibilityIdentifier(A11yID.workDetailView)
    }

    private var isFavorite: Bool {
        favorites.contains { $0.linkedID == work.id && $0.linkedKindRaw == UserLinkedKind.work.rawValue }
    }

    private var isSeen: Bool {
        seenRecords.contains { $0.workID == work.id }
    }

    private var actionBar: some View {
        HStack {
            Button {
                AppHaptics.secondary()
                toggleFavorite()
            } label: {
                Label(isFavorite ? "Favorited" : "Favorite", systemImage: isFavorite ? "heart.fill" : "heart")
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier(A11yID.favoriteButton)

            Button {
                AppHaptics.secondary()
                toggleSeen()
            } label: {
                Label(isSeen ? "Seen" : "Seen", systemImage: isSeen ? "checkmark.circle.fill" : "checkmark.circle")
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier(A11yID.seenButton)

            Button {
                showingNoteEditor = true
            } label: {
                Label("Note", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier(A11yID.addNoteButton)
        }
        .labelStyle(.titleAndIcon)
        .dynamicTypeSize(...DynamicTypeSize.accessibility3)
    }

    private func toggleFavorite() {
        if let existing = favorites.first(where: { $0.linkedID == work.id && $0.linkedKindRaw == UserLinkedKind.work.rawValue }) {
            modelContext.delete(existing)
        } else {
            modelContext.insert(FavoriteRecord(linkedKind: .work, linkedID: work.id))
        }
    }

    private func toggleSeen() {
        if let existing = seenRecords.first(where: { $0.workID == work.id }) {
            modelContext.delete(existing)
        } else {
            modelContext.insert(SeenRecord(workID: work.id))
        }
    }
}
