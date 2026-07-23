import SwiftData
import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var contentStore: AppContentStore
    @Query private var notes: [ReadingNote]
    @State private var query = ""

    var results: [SearchResult] {
        SearchService.search(query, content: contentStore.content, notes: notes, language: contentStore.language)
    }

    var body: some View {
        List {
            if query.isEmpty {
                ContentUnavailableView("Search the app", systemImage: "magnifyingglass", description: Text("Search works, topics, paths, and your notes."))
            } else if results.isEmpty {
                ContentUnavailableView.search(text: query)
            } else {
                ForEach(SearchResultKind.allCases) { kind in
                    let grouped = results.filter { $0.kind == kind }
                    if !grouped.isEmpty {
                        Section(kind.rawValue.capitalized) {
                            ForEach(grouped) { result in
                                resultRow(result)
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $query, prompt: "Works, topics, paths, notes")
        .navigationTitle(String(localized: "tab.search"))
        .accessibilityIdentifier(A11yID.searchView)
    }

    @ViewBuilder
    private func resultRow(_ result: SearchResult) -> some View {
        if let linkedKind = result.linkedKind, let linkedID = result.linkedID, let route = route(kind: linkedKind, id: linkedID) {
            NavigationLink(value: route) {
                resultContent(result)
            }
            .accessibilityIdentifier("search.result.\(result.id)")
        } else {
            resultContent(result)
                .accessibilityIdentifier("search.result.\(result.id)")
        }
    }

    private func resultContent(_ result: SearchResult) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xxSmall) {
            Text(result.title)
                .font(.headline)
            Text(result.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(result.snippet)
                .font(.subheadline)
                .lineLimit(3)
        }
        .padding(.vertical, Spacing.xSmall)
    }

    private func route(kind: ContentLinkKind, id: String) -> AppRoute? {
        switch kind {
        case .work: .workDetail(id)
        case .topic: .topicDetail(id)
        case .route, .audioStop: .routeDetail(id)
        case .source: nil
        }
    }
}
