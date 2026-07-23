import Foundation
import SwiftData

enum UserLinkedKind: String, Codable, CaseIterable {
    case work
    case topic
    case route
    case source
    case audioStop
}

@Model
final class ReadingNote {
    @Attribute(.unique) var id: String
    var linkedKindRaw: String
    var linkedID: String
    var title: String
    var body: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        linkedKind: UserLinkedKind,
        linkedID: String,
        title: String,
        body: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.linkedKindRaw = linkedKind.rawValue
        self.linkedID = linkedID
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var linkedKind: UserLinkedKind {
        UserLinkedKind(rawValue: linkedKindRaw) ?? .work
    }
}

@Model
final class FavoriteRecord {
    @Attribute(.unique) var id: String
    var linkedKindRaw: String
    var linkedID: String
    var createdAt: Date

    init(linkedKind: UserLinkedKind, linkedID: String, createdAt: Date = Date()) {
        self.id = "\(linkedKind.rawValue)-\(linkedID)"
        self.linkedKindRaw = linkedKind.rawValue
        self.linkedID = linkedID
        self.createdAt = createdAt
    }
}

@Model
final class SeenRecord {
    @Attribute(.unique) var id: String
    var workID: String
    var createdAt: Date

    init(workID: String, createdAt: Date = Date()) {
        self.id = workID
        self.workID = workID
        self.createdAt = createdAt
    }
}

@Model
final class RouteProgressRecord {
    @Attribute(.unique) var id: String
    var routeID: String
    var currentStopID: String?
    var completedStopIDs: [String]
    var updatedAt: Date

    init(routeID: String, currentStopID: String? = nil, completedStopIDs: [String] = [], updatedAt: Date = Date()) {
        self.id = routeID
        self.routeID = routeID
        self.currentStopID = currentStopID
        self.completedStopIDs = completedStopIDs
        self.updatedAt = updatedAt
    }
}

enum PlaybackState: String, Codable, CaseIterable {
    case idle
    case speaking
    case paused
    case stopped
    case completed
}

@Model
final class PlaybackProgressRecord {
    @Attribute(.unique) var id: String
    var routeID: String?
    var stopID: String?
    var speed: Double
    var stateRaw: String
    var updatedAt: Date

    init(
        id: String = "global-playback",
        routeID: String? = nil,
        stopID: String? = nil,
        speed: Double = 0.5,
        state: PlaybackState = .idle,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.routeID = routeID
        self.stopID = stopID
        self.speed = speed
        self.stateRaw = state.rawValue
        self.updatedAt = updatedAt
    }

    var state: PlaybackState {
        get { PlaybackState(rawValue: stateRaw) ?? .idle }
        set {
            stateRaw = newValue.rawValue
            updatedAt = Date()
        }
    }
}

enum AppSchema {
    static var userModels: [any PersistentModel.Type] {
        [
            ReadingNote.self,
            FavoriteRecord.self,
            SeenRecord.self,
            RouteProgressRecord.self,
            PlaybackProgressRecord.self
        ]
    }
}

