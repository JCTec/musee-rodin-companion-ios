import SwiftUI

struct RootView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var contentStore: AppContentStore
    @State private var selectedSidebar: AppTab = .places

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                iPadRoot
            } else {
                iPhoneRoot
            }
        }
        .background(AppColor.background)
    }

    private var iPhoneRoot: some View {
        TabView {
            NavigationStack {
                PlacesView()
                    .navigationDestination(for: AppRoute.self, destination: destination)
            }
            .tabItem { Label(String(localized: "tab.places"), systemImage: "building.columns") }
            .accessibilityIdentifier("tab.places")

            NavigationStack {
                WorksView()
                    .navigationDestination(for: AppRoute.self, destination: destination)
            }
            .tabItem { Label(String(localized: "tab.works"), systemImage: "diamond") }
            .accessibilityIdentifier("tab.works")

            NavigationStack {
                PathsView()
                    .navigationDestination(for: AppRoute.self, destination: destination)
            }
            .tabItem { Label(String(localized: "tab.paths"), systemImage: "map") }
            .accessibilityIdentifier("tab.paths")

            NavigationStack {
                SearchView()
                    .navigationDestination(for: AppRoute.self, destination: destination)
            }
            .tabItem { Label(String(localized: "tab.search"), systemImage: "magnifyingglass") }
            .accessibilityIdentifier("tab.search")

            NavigationStack {
                NotesView()
                    .navigationDestination(for: AppRoute.self, destination: destination)
            }
            .tabItem { Label(String(localized: "tab.notes"), systemImage: "note.text") }
            .accessibilityIdentifier("tab.notes")
        }
    }

    private var iPadRoot: some View {
        NavigationSplitView {
            List {
                ForEach(AppTab.allCases) { tab in
                    Button {
                        selectedSidebar = tab
                    } label: {
                        Label(label(for: tab), systemImage: symbol(for: tab))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(selectedSidebar == tab ? AppColor.bronze : .primary)
                    .accessibilityValue(selectedSidebar == tab ? "selected" : "not selected")
                    .accessibilityIdentifier("sidebar.\(tab.rawValue)")
                }
            }
            .navigationTitle(String(localized: "app.title"))
        } detail: {
            NavigationStack {
                Group {
                    switch selectedSidebar {
                    case .places: PlacesView()
                    case .works: WorksView()
                    case .paths: PathsView()
                    case .search: SearchView()
                    case .notes: NotesView()
                    }
                }
                .navigationDestination(for: AppRoute.self, destination: destination)
            }
            .id(selectedSidebar)
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .workDetail(let id):
            if let work = contentStore.content.work(id: id) {
                WorkDetailView(work: work)
            } else {
                ContentUnavailableView("Work not found", systemImage: "exclamationmark.triangle")
            }
        case .topicDetail(let id):
            if let topic = contentStore.content.topic(id: id) {
                TopicDetailView(topic: topic)
            } else {
                ContentUnavailableView("Topic not found", systemImage: "exclamationmark.triangle")
            }
        case .routeDetail(let id):
            if let route = contentStore.content.route(id: id) {
                PathDetailView(route: route)
            } else {
                ContentUnavailableView("Path not found", systemImage: "exclamationmark.triangle")
            }
        }
    }

    private func label(for tab: AppTab) -> String {
        switch tab {
        case .places: String(localized: "tab.places")
        case .works: String(localized: "tab.works")
        case .paths: String(localized: "tab.paths")
        case .search: String(localized: "tab.search")
        case .notes: String(localized: "tab.notes")
        }
    }

    private func symbol(for tab: AppTab) -> String {
        switch tab {
        case .places: "building.columns"
        case .works: "diamond"
        case .paths: "map"
        case .search: "magnifyingglass"
        case .notes: "note.text"
        }
    }
}
