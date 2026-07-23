import SwiftUI

struct TopicDetailView: View {
    @EnvironmentObject private var contentStore: AppContentStore
    var topic: Topic

    var body: some View {
        List {
            Section {
                PlaceholderPanel(symbol: topic.placeholderSymbol, label: "topic placeholder")
                VStack(alignment: .leading, spacing: Spacing.small) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(topic.title.value(for: contentStore.language))
                                .font(.title.bold())
                            Text(topic.subtitle.value(for: contentStore.language))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        ConfidenceChip(confidence: topic.confidence)
                    }
                    Text(topic.summary.value(for: contentStore.language))
                }
                .padding(.vertical, Spacing.small)
            }

            Section("Research note") {
                Text(topic.researchNote.value(for: contentStore.language))
            }

            Section("Related works") {
                ForEach(topic.relatedWorkIDs, id: \.self) { id in
                    if let work = contentStore.content.work(id: id) {
                        WorkRow(work: work)
                    }
                }
            }

            Section("Sources") {
                FlowLayout(spacing: Spacing.xSmall) {
                    ForEach(topic.citations) { citation in
                        CitationChip(citation: citation)
                    }
                }
                .padding(.vertical, Spacing.xSmall)
            }
        }
        .navigationTitle(topic.title.value(for: contentStore.language))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("topicDetail.view")
    }
}
