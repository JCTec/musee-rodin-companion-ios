import AVFoundation
import SwiftUI
import UIKit

struct PlaceholderPanel: View {
    var symbol: String
    var label: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: CornerRadiusToken.medium, style: .continuous)
                .fill(AppColor.bronze.opacity(0.22))
                .overlay(alignment: .center) {
                    Image(systemName: symbol)
                        .font(.largeTitle)
                        .foregroundStyle(AppColor.bronze)
                }
            Text(label)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
                .padding(Spacing.xSmall)
                .background(.thinMaterial, in: Capsule())
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .accessibilityLabel(label)
    }
}

enum WorkArtworkStyle {
    case thumbnail
    case hero
}

struct WorkArtworkImage: View {
    @EnvironmentObject private var contentStore: AppContentStore
    var work: Work
    var style: WorkArtworkStyle
    var onOpenFullScreen: (() -> Void)? = nil

    var body: some View {
        switch style {
        case .thumbnail:
            thumbnail
        case .hero:
            hero
        }
    }

    @ViewBuilder
    private var thumbnail: some View {
        if hasAsset {
            Image(work.id)
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.small, style: .continuous))
                .accessibilityHidden(true)
        } else {
            RoundedRectangle(cornerRadius: CornerRadiusToken.small, style: .continuous)
                .fill(AppColor.bronze.opacity(0.18))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: work.placeholderSymbol)
                        .foregroundStyle(AppColor.bronze)
                }
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private var hero: some View {
        if hasAsset {
            if let onOpenFullScreen {
                Button {
                    AppHaptics.secondary()
                    onOpenFullScreen()
                } label: {
                    heroArtwork
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open full screen image for \(work.title.value(for: contentStore.language))")
                .accessibilityHint("Shows the artwork image full screen")
                .accessibilityIdentifier("work.image.\(work.id)")
            } else {
                heroArtwork
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(accessibilityLabel)
                    .accessibilityIdentifier("work.image.\(work.id)")
            }
        } else {
            PlaceholderPanel(symbol: work.placeholderSymbol, label: "work image unavailable")
                .accessibilityIdentifier("work.image.\(work.id)")
        }
    }

    private var heroArtwork: some View {
        ZStack {
            RoundedRectangle(cornerRadius: CornerRadiusToken.medium, style: .continuous)
                .fill(AppColor.card)
            Image(work.id)
                .resizable()
                .scaledToFit()
                .padding(Spacing.small)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.medium, style: .continuous))
    }

    private var hasAsset: Bool {
        UIImage(named: work.id) != nil
    }

    private var accessibilityLabel: String {
        "Artwork image for \(work.title.value(for: contentStore.language))"
    }
}

struct FullScreenArtworkView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var contentStore: AppContentStore
    var work: Work

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: Spacing.medium) {
                Spacer(minLength: Spacing.large)

                Image(work.id)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, Spacing.medium)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(accessibilityLabel)
                    .accessibilityIdentifier("work.fullScreenImage.image.\(work.id)")

                Text(work.title.value(for: contentStore.language))
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.large)
                    .accessibilityIdentifier("work.fullScreenImage.title.\(work.id)")

                Text("\(work.artist) - \(work.dateText)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.large)

                Spacer(minLength: Spacing.large)
            }
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline.weight(.semibold))
                        .frame(width: 48, height: 48)
                        .foregroundStyle(.white)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .accessibilityLabel("Close full screen image")
                .accessibilityIdentifier("work.fullScreenImage.closeButton")
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.top, Spacing.xSmall)
        }
    }

    private var accessibilityLabel: String {
        "Full screen artwork image for \(work.title.value(for: contentStore.language))"
    }
}

struct CitationChip: View {
    @EnvironmentObject private var contentStore: AppContentStore
    @Environment(\.openURL) private var openURL
    var citation: Citation

    var body: some View {
        Button {
            if let sourceURL {
                openURL(sourceURL)
            }
        } label: {
            Label {
                Text(displayTitle)
            } icon: {
                Image(systemName: "arrow.up.right.square")
            }
            .labelStyle(.titleAndIcon)
            .font(.caption2.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, Spacing.small)
            .padding(.vertical, Spacing.xSmall)
            .background(Color.primary.opacity(0.07), in: Capsule())
            .fixedSize(horizontal: true, vertical: false)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(sourceURL == nil)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Opens the original source URL")
        .accessibilityIdentifier("citation.\(citation.id)")
    }

    private var sourceURL: URL? {
        citation.url ?? contentStore.content.source(id: citation.sourceID)?.url
    }

    private var source: Source? {
        contentStore.content.source(id: citation.sourceID)
    }

    private var displayTitle: String {
        if let page = citation.page {
            return "PDF p.\(page)"
        }

        if source?.kind == .pdf {
            return "PDF source"
        }

        return "Official page"
    }

    private var accessibilityLabel: String {
        let sourceTitle = source?.title.value(for: contentStore.language) ?? displayTitle
        if let page = citation.page {
            return "Open PDF source, \(sourceTitle), page \(page)"
        }
        return "Open \(displayTitle), \(sourceTitle)"
    }
}

struct ConfidenceChip: View {
    var confidence: ContentConfidence

    var body: some View {
        Label(label, systemImage: symbol)
            .font(.caption)
            .foregroundStyle(foreground)
            .padding(.horizontal, Spacing.small)
            .padding(.vertical, Spacing.xSmall)
            .background(foreground.opacity(0.14), in: Capsule())
            .accessibilityLabel(label)
    }

    private var label: String {
        switch confidence {
        case .verified: "Verified"
        case .reviewNeeded: "Review needed"
        case .sourceNeeded: "Source needed"
        case .tertiary: "Tertiary source"
        }
    }

    private var symbol: String {
        switch confidence {
        case .verified: "checkmark.seal"
        case .reviewNeeded: "exclamationmark.triangle"
        case .sourceNeeded: "questionmark.circle"
        case .tertiary: "books.vertical"
        }
    }

    private var foreground: Color {
        switch confidence {
        case .verified: AppColor.patina
        case .reviewNeeded: .orange
        case .sourceNeeded: .red
        case .tertiary: .secondary
        }
    }
}

struct TagChip: View {
    var title: String

    var body: some View {
        Text(title)
            .font(.caption)
            .padding(.horizontal, Spacing.small)
            .padding(.vertical, Spacing.xSmall)
            .background(Color.primary.opacity(0.08), in: Capsule())
            .accessibilityLabel(title)
    }
}

struct MetadataGrid: View {
    var items: [(String, String)]

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: Spacing.medium, verticalSpacing: Spacing.small) {
            ForEach(items, id: \.0) { item in
                GridRow {
                    Text(item.0.uppercased())
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(item.1)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct WorkRow: View {
    @EnvironmentObject private var contentStore: AppContentStore
    var work: Work

    var body: some View {
        NavigationLink(value: AppRoute.workDetail(work.id)) {
            HStack(spacing: Spacing.medium) {
                WorkArtworkImage(work: work, style: .thumbnail)
                VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                    Text(work.title.value(for: contentStore.language))
                        .font(.headline)
                    Text("\(work.artist) - \(work.dateText)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(work.material.value(for: contentStore.language))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, Spacing.xSmall)
        }
        .accessibilityLabel("\(work.title.value(for: contentStore.language)), \(work.artist), \(work.dateText)")
        .accessibilityIdentifier("work.row.\(work.id)")
    }
}

struct ReadAloudButton: View {
    @EnvironmentObject private var contentStore: AppContentStore
    @EnvironmentObject private var narrator: NarrationController
    var stop: AudioStop

    var body: some View {
        Button {
            AppHaptics.primary()
            narrator.toggle(stop: stop, language: contentStore.language)
        } label: {
            HStack {
                Image(systemName: icon)
                    .imageScale(.large)
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Text("\(max(1, stop.durationSecondsEstimate / 60)) min - \(contentStore.language.rawValue.uppercased())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(speedLabel)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .padding(Spacing.medium)
            .background(AppColor.bronze.opacity(0.92), in: RoundedRectangle(cornerRadius: CornerRadiusToken.medium, style: .continuous))
            .foregroundStyle(.black)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(title)
        .accessibilityValue(accessibilityValue)
        .accessibilityHint("Reads this stop aloud using the system voice")
        .accessibilityIdentifier(A11yID.readAloudButton)
    }

    private var isCurrent: Bool {
        narrator.stateMachine.currentStopID == stop.id
    }

    private var title: String {
        if isCurrent && narrator.stateMachine.state == .speaking {
            return "Pause read aloud"
        }
        if isCurrent && narrator.stateMachine.state == .paused {
            return "Resume read aloud"
        }
        return "Read aloud"
    }

    private var icon: String {
        if isCurrent && narrator.stateMachine.state == .speaking { return "pause.fill" }
        return "play.fill"
    }

    private var speedLabel: String {
        String(format: "%.1fx", narrator.rate / AVSpeechUtteranceDefaultSpeechRate)
    }

    private var accessibilityValue: String {
        if isCurrent {
            return narrator.stateMachine.state.rawValue
        }
        return "stopped"
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat

    init(spacing: CGFloat = Spacing.xSmall) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = rows(for: subviews, proposal: proposal)
        return CGSize(
            width: proposal.width ?? rows.map(\.width).max() ?? 0,
            height: rows.last.map { $0.y + $0.height } ?? 0
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = rows(for: subviews, proposal: proposal)
        for row in rows {
            for item in row.items {
                subviews[item.index].place(at: CGPoint(x: bounds.minX + item.x, y: bounds.minY + row.y), proposal: ProposedViewSize(item.size))
            }
        }
    }

    private func rows(for subviews: Subviews, proposal: ProposedViewSize) -> [FlowRow] {
        let maxWidth = proposal.width ?? 320
        var rows: [FlowRow] = []
        var currentItems: [FlowItem] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var currentHeight: CGFloat = 0

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, !currentItems.isEmpty {
                rows.append(FlowRow(y: currentY, height: currentHeight, width: currentX - spacing, items: currentItems))
                currentY += currentHeight + spacing
                currentItems = []
                currentX = 0
                currentHeight = 0
            }
            currentItems.append(FlowItem(index: index, x: currentX, size: size))
            currentX += size.width + spacing
            currentHeight = max(currentHeight, size.height)
        }

        if !currentItems.isEmpty {
            rows.append(FlowRow(y: currentY, height: currentHeight, width: max(0, currentX - spacing), items: currentItems))
        }
        return rows
    }
}

private struct FlowRow {
    var y: CGFloat
    var height: CGFloat
    var width: CGFloat
    var items: [FlowItem]
}

private struct FlowItem {
    var index: Int
    var x: CGFloat
    var size: CGSize
}
