import Foundation

enum AppLanguage: String, Codable, CaseIterable, Identifiable, Sendable {
    case en
    case fr
    case es

    var id: String { rawValue }
}

struct LocalizedText: Codable, Hashable, Sendable {
    var en: String
    var fr: String
    var es: String
    var reviewNeeded: Bool?

    func value(for language: AppLanguage) -> String {
        switch language {
        case .en: en
        case .fr: fr
        case .es: es
        }
    }

    static func same(_ value: String) -> LocalizedText {
        LocalizedText(en: value, fr: value, es: value, reviewNeeded: false)
    }
}

enum SourceKind: String, Codable, CaseIterable, Sendable {
    case web
    case pdf
}

enum ContentConfidence: String, Codable, CaseIterable, Sendable {
    case verified
    case reviewNeeded
    case sourceNeeded
    case tertiary
}

enum ContentLinkKind: String, Codable, CaseIterable, Sendable {
    case work
    case topic
    case route
    case source
    case audioStop
}

struct Citation: Codable, Hashable, Identifiable, Sendable {
    var id: String
    var sourceID: String
    var label: String
    var page: Int?
    var url: URL?
    var note: LocalizedText?
}

struct Source: Codable, Identifiable, Hashable, Sendable {
    var id: String
    var kind: SourceKind
    var title: LocalizedText
    var publisher: String
    var url: URL
    var accessDate: String
    var localFilename: String?
    var notes: LocalizedText
}

struct SourceChunk: Codable, Identifiable, Hashable, Sendable {
    var id: String
    var sourceID: String
    var page: Int?
    var sectionHint: LocalizedText?
    var text: LocalizedText
    var citation: Citation
}

struct Work: Codable, Identifiable, Hashable, Sendable {
    var id: String
    var title: LocalizedText
    var artist: String
    var dateText: String
    var material: LocalizedText
    var inventoryNumber: String?
    var locationStatus: LocalizedText
    var summary: LocalizedText
    var researchNote: LocalizedText
    var confidence: ContentConfidence
    var tags: [String]
    var citations: [Citation]
    var relatedTopicIDs: [String]
    var placeholderSymbol: String
}

struct Topic: Codable, Identifiable, Hashable, Sendable {
    var id: String
    var title: LocalizedText
    var subtitle: LocalizedText
    var summary: LocalizedText
    var researchNote: LocalizedText
    var confidence: ContentConfidence
    var tags: [String]
    var citations: [Citation]
    var relatedWorkIDs: [String]
    var placeholderSymbol: String
}

struct Route: Codable, Identifiable, Hashable, Sendable {
    var id: String
    var title: LocalizedText
    var subtitle: LocalizedText
    var summary: LocalizedText
    var estimatedMinutes: Int
    var stopIDs: [String]
    var tags: [String]
    var citations: [Citation]
}

struct AudioStop: Codable, Identifiable, Hashable, Sendable {
    var id: String
    var title: LocalizedText
    var subtitle: LocalizedText
    var linkedKind: ContentLinkKind
    var linkedID: String
    var routeIDs: [String]
    var order: Int
    var script: LocalizedText
    var durationSecondsEstimate: Int
    var citations: [Citation]
    var tags: [String]
}

struct ContentRepository: Codable, Sendable {
    var sources: [Source]
    var sourceChunks: [SourceChunk]
    var works: [Work]
    var topics: [Topic]
    var routes: [Route]
    var audioStops: [AudioStop]
}

extension ContentRepository {
    static func load(from bundle: Bundle = .main) throws -> ContentRepository {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return ContentRepository(
            sources: try decode("sources", from: bundle, decoder: decoder),
            sourceChunks: try decode("source_chunks", from: bundle, decoder: decoder),
            works: try decode("works", from: bundle, decoder: decoder),
            topics: try decode("topics", from: bundle, decoder: decoder),
            routes: try decode("routes", from: bundle, decoder: decoder),
            audioStops: try decode("audio_stops", from: bundle, decoder: decoder)
        )
    }

    static var empty: ContentRepository {
        ContentRepository(sources: [], sourceChunks: [], works: [], topics: [], routes: [], audioStops: [])
    }

    private static func decode<T: Decodable>(_ resource: String, from bundle: Bundle, decoder: JSONDecoder) throws -> [T] {
        guard let url = bundle.url(forResource: resource, withExtension: "json") else {
            throw ContentLoadError.missingResource(resource)
        }
        let data = try Data(contentsOf: url)
        return try decoder.decode([T].self, from: data)
    }
}

enum ContentLoadError: LocalizedError {
    case missingResource(String)

    var errorDescription: String? {
        switch self {
        case .missingResource(let name):
            "Missing bundled content resource: \(name).json"
        }
    }
}

extension ContentRepository {
    func source(id: String) -> Source? {
        sources.first { $0.id == id }
    }

    func work(id: String) -> Work? {
        works.first { $0.id == id }
    }

    func topic(id: String) -> Topic? {
        topics.first { $0.id == id }
    }

    func route(id: String) -> Route? {
        routes.first { $0.id == id }
    }

    func audioStop(id: String) -> AudioStop? {
        audioStops.first { $0.id == id }
    }
}

