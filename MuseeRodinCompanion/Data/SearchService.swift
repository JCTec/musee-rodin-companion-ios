import Foundation

enum SearchResultKind: String, CaseIterable, Identifiable {
    case work
    case topic
    case route
    case note

    var id: String { rawValue }
}

struct SearchResult: Identifiable, Hashable {
    var id: String
    var kind: SearchResultKind
    var title: String
    var subtitle: String
    var snippet: String
    var linkedKind: ContentLinkKind?
    var linkedID: String?
}

enum SearchService {
    static func search(_ query: String, content: ContentRepository, notes: [ReadingNote], language: AppLanguage) -> [SearchResult] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        let needle = trimmed.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)

        func matches(_ values: String...) -> Bool {
            values.contains { value in
                value.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).contains(needle)
            }
        }

        var results: [SearchResult] = []

        for work in content.works where matches(work.title.value(for: language), work.artist, work.summary.value(for: language), work.tags.joined(separator: " ")) {
            results.append(SearchResult(id: "work-\(work.id)", kind: .work, title: work.title.value(for: language), subtitle: work.artist, snippet: work.summary.value(for: language), linkedKind: .work, linkedID: work.id))
        }

        for topic in content.topics where matches(topic.title.value(for: language), topic.summary.value(for: language), topic.tags.joined(separator: " ")) {
            results.append(SearchResult(id: "topic-\(topic.id)", kind: .topic, title: topic.title.value(for: language), subtitle: topic.subtitle.value(for: language), snippet: topic.summary.value(for: language), linkedKind: .topic, linkedID: topic.id))
        }

        for route in content.routes where matches(route.title.value(for: language), route.summary.value(for: language), route.tags.joined(separator: " ")) {
            results.append(SearchResult(id: "route-\(route.id)", kind: .route, title: route.title.value(for: language), subtitle: route.subtitle.value(for: language), snippet: route.summary.value(for: language), linkedKind: .route, linkedID: route.id))
        }

        for note in notes where matches(note.title, note.body) {
            results.append(SearchResult(id: "note-\(note.id)", kind: .note, title: note.title, subtitle: note.linkedKindRaw, snippet: note.body, linkedKind: nil, linkedID: nil))
        }

        return results
    }
}
