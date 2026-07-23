import SwiftUI

struct PathsView: View {
    @EnvironmentObject private var contentStore: AppContentStore

    var body: some View {
        List {
            Section {
                Text("Symbolic paths connect works, places, and themes. Audio is attached to each stop so you can read, listen, and open the related item in context.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Paths") {
                ForEach(contentStore.content.routes) { route in
                    NavigationLink(value: AppRoute.routeDetail(route.id)) {
                        VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                            Text(route.title.value(for: contentStore.language))
                                .font(.headline)
                            Text(route.subtitle.value(for: contentStore.language))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("\(route.stopIDs.count) stops - \(route.estimatedMinutes) min")
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, Spacing.xSmall)
                    }
                    .accessibilityLabel("\(route.title.value(for: contentStore.language)), \(route.stopIDs.count) stops")
                    .accessibilityIdentifier("path.row.\(route.id)")
                }
            }
        }
        .navigationTitle(String(localized: "tab.paths"))
        .accessibilityIdentifier(A11yID.pathsView)
    }
}

struct PathDetailView: View {
    @EnvironmentObject private var contentStore: AppContentStore
    @EnvironmentObject private var narrator: NarrationController
    var route: Route

    private var stops: [AudioStop] {
        route.stopIDs.compactMap { id in
            contentStore.content.audioStop(id: id)
        }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text(route.title.value(for: contentStore.language))
                        .font(.title.bold())
                    Text(route.summary.value(for: contentStore.language))
                        .font(.body)
                    HStack {
                        Label("\(stops.count) stops", systemImage: "list.number")
                        Label("\(route.estimatedMinutes) min", systemImage: "clock")
                    }
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, Spacing.small)
            }

            ForEach(Array(stops.enumerated()), id: \.element.id) { index, stop in
                Section {
                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        VStack(alignment: .leading, spacing: Spacing.xSmall) {
                            Text(stop.title.value(for: contentStore.language))
                                .font(.headline)
                            Text(stop.subtitle.value(for: contentStore.language))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(stop.script.value(for: contentStore.language))
                                .font(.body)
                        }

                        ReadAloudButton(stop: stop)
                    }
                    .padding(.vertical, Spacing.small)
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("path.stop.\(stop.id)")

                    NavigationLink(value: routeForLinkedItem(stop)) {
                        Label(linkedItemTitle(for: stop), systemImage: linkedItemSymbol(for: stop))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .accessibilityLabel(linkedItemAccessibilityLabel(for: stop))
                    .accessibilityIdentifier("path.stop.itemButton.\(stop.id)")

                    if let nextStop = stops[safe: index + 1] {
                        VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                            Label("Next stop", systemImage: "arrow.down")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(nextStop.title.value(for: contentStore.language))
                                .font(.subheadline.weight(.semibold))
                            Text(nextStop.subtitle.value(for: contentStore.language))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, Spacing.xSmall)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityElement(children: .combine)
                        .accessibilityIdentifier("path.stop.nextStop.\(stop.id)")
                    }

                    if !stop.citations.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.xSmall) {
                            Text("Sources")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            FlowLayout(spacing: Spacing.xSmall) {
                                ForEach(stop.citations) { citation in
                                    CitationChip(citation: citation)
                                }
                            }
                        }
                        .padding(.vertical, Spacing.xSmall)
                        .accessibilityIdentifier("path.stop.sources.\(stop.id)")
                    }
                } header: {
                    Text("Stop \(index + 1)")
                        .accessibilityIdentifier("path.stop.number.\(stop.id)")
                }
            }
        }
        .navigationTitle(route.title.value(for: contentStore.language))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    narrator.stop()
                } label: {
                    Image(systemName: "stop.fill")
                }
                .accessibilityLabel("Stop read aloud")
                .accessibilityIdentifier("readAloud.stopButton")
            }
        }
        .accessibilityIdentifier(A11yID.pathDetailView)
    }

    private func routeForLinkedItem(_ stop: AudioStop) -> AppRoute {
        switch stop.linkedKind {
        case .work:
            return .workDetail(stop.linkedID)
        case .topic:
            return .topicDetail(stop.linkedID)
        case .route:
            return .routeDetail(stop.linkedID)
        case .source, .audioStop:
            return .routeDetail(route.id)
        }
    }

    private func linkedItemTitle(for stop: AudioStop) -> String {
        switch stop.linkedKind {
        case .work:
            if let work = contentStore.content.work(id: stop.linkedID) {
                return "Open work: \(work.title.value(for: contentStore.language))"
            }
        case .topic:
            if let topic = contentStore.content.topic(id: stop.linkedID) {
                return "Open item: \(topic.title.value(for: contentStore.language))"
            }
        case .route:
            if let linkedRoute = contentStore.content.route(id: stop.linkedID) {
                return "Open path: \(linkedRoute.title.value(for: contentStore.language))"
            }
        case .source, .audioStop:
            break
        }
        return "Open linked item"
    }

    private func linkedItemAccessibilityLabel(for stop: AudioStop) -> String {
        switch stop.linkedKind {
        case .work:
            return "Open related work"
        case .topic:
            return "Open related item"
        case .route:
            return "Open related path"
        case .source, .audioStop:
            return "Open linked item"
        }
    }

    private func linkedItemSymbol(for stop: AudioStop) -> String {
        switch stop.linkedKind {
        case .work:
            return "diamond"
        case .topic:
            return "book.closed"
        case .route:
            return "map"
        case .source:
            return "doc.text"
        case .audioStop:
            return "play"
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
