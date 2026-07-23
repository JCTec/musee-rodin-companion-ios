import SwiftUI

enum WorkFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case rodin = "Rodin"
    case claudel = "Claudel"
    case garden = "Garden"
    case meudon = "Meudon"
    case drawing = "Drawing"

    var id: String { rawValue }
}

struct WorksView: View {
    @EnvironmentObject private var contentStore: AppContentStore
    @State private var query = ""
    @State private var filter: WorkFilter = .all

    var body: some View {
        List {
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(WorkFilter.allCases) { candidate in
                            Button(candidate.rawValue) {
                                AppHaptics.secondary()
                                filter = candidate
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .tint(filter == candidate ? AppColor.bronze : .secondary)
                            .accessibilityIdentifier("works.filter.\(candidate.rawValue)")
                        }
                    }
                    .padding(.vertical, Spacing.xSmall)
                }
            }

            Section("\(filteredWorks.count) of \(contentStore.content.works.count) shown") {
                ForEach(filteredWorks) { work in
                    WorkRow(work: work)
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $query, prompt: "Titles, materials, notes")
        .accessibilityIdentifier(A11yID.worksView)
        .navigationTitle(String(localized: "tab.works"))
    }

    private var filteredWorks: [Work] {
        contentStore.content.works.filter { work in
            filterMatches(work) && queryMatches(work)
        }
    }

    private func filterMatches(_ work: Work) -> Bool {
        switch filter {
        case .all: true
        case .rodin: work.artist.localizedCaseInsensitiveContains("Rodin")
        case .claudel: work.artist.localizedCaseInsensitiveContains("Claudel")
        case .garden: work.tags.contains("garden")
        case .meudon: work.tags.contains("meudon")
        case .drawing: work.tags.contains("drawing")
        }
    }

    private func queryMatches(_ work: Work) -> Bool {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return true }
        let fields = [
            work.title.value(for: contentStore.language),
            work.artist,
            work.material.value(for: contentStore.language),
            work.summary.value(for: contentStore.language),
            work.tags.joined(separator: " ")
        ]
        return fields.contains { $0.localizedCaseInsensitiveContains(query) }
    }
}

