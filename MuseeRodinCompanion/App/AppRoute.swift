import Foundation

enum AppTab: String, CaseIterable, Identifiable {
    case places
    case works
    case paths
    case search
    case notes

    var id: String { rawValue }
}

enum AppRoute: Hashable {
    case workDetail(String)
    case topicDetail(String)
    case routeDetail(String)
}
