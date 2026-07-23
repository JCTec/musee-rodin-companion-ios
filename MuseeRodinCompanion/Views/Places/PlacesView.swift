import SwiftUI

struct PlacesView: View {
    @EnvironmentObject private var contentStore: AppContentStore

    private let places: [PlaceReference] = [
        PlaceReference(topicID: "topic-hotel-biron", symbol: "building.columns"),
        PlaceReference(topicID: "topic-garden", symbol: "leaf"),
        PlaceReference(topicID: "topic-meudon", symbol: "house")
    ]

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("PERSONAL COMPANION")
                        .font(.caption)
                        .foregroundStyle(AppColor.bronze)
                    Text(String(localized: "app.title"))
                        .font(.largeTitle.weight(.semibold))
                    Text("A private notebook and audio guide. \(contentStore.content.works.count) works catalogued and growing.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, Spacing.small)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("places.heroCard")
            }

            Section("Places") {
                ForEach(places) { place in
                    if let topic = contentStore.content.topic(id: place.topicID) {
                        placeLink(topic: topic, symbol: place.symbol)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppColor.background)
        .navigationTitle(String(localized: "tab.places"))
        .navigationBarTitleDisplayMode(.large)
        .accessibilityIdentifier(A11yID.placesView)
    }

    private func placeLink(topic: Topic, symbol: String) -> some View {
        NavigationLink(value: AppRoute.topicDetail(topic.id)) {
            Label {
                VStack(alignment: .leading) {
                    Text(topic.title.value(for: contentStore.language))
                    Text(topic.subtitle.value(for: contentStore.language))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: symbol)
            }
        }
        .accessibilityLabel("\(topic.title.value(for: contentStore.language)), \(topic.subtitle.value(for: contentStore.language))")
        .accessibilityIdentifier("place.row.\(topic.id)")
    }
}

private struct PlaceReference: Identifiable {
    var topicID: String
    var symbol: String

    var id: String { topicID }
}
