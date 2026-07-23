import SwiftData
import XCTest
@testable import MuseeRodinCompanion

final class ContentModelTests: XCTestCase {
    func testPopulatedContentDecodesForAllLanguages() throws {
        let content = try ContentRepository.load(from: .main)

        XCTAssertEqual(content.works.count, 18)
        XCTAssertEqual(content.sources.count, 47)
        XCTAssertEqual(content.sourceChunks.count, 28)
        XCTAssertEqual(content.topics.count, 16)
        XCTAssertEqual(content.routes.count, 12)
        XCTAssertEqual(content.audioStops.count, 29)

        for language in AppLanguage.allCases {
            XCTAssertFalse(content.works[0].title.value(for: language).isEmpty)
            XCTAssertFalse(content.topics[0].summary.value(for: language).isEmpty)
            XCTAssertFalse(content.audioStops[0].script.value(for: language).isEmpty)
        }
    }

    func testEveryCitedSourceExists() throws {
        let content = try ContentRepository.load(from: .main)
        let sourceIDs = Set(content.sources.map(\.id))

        let citations = content.works.flatMap(\.citations)
            + content.topics.flatMap(\.citations)
            + content.routes.flatMap(\.citations)
            + content.audioStops.flatMap(\.citations)
            + content.sourceChunks.map(\.citation)

        XCTAssertFalse(citations.isEmpty)
        for citation in citations {
            XCTAssertTrue(sourceIDs.contains(citation.sourceID), "Missing source for citation \(citation.id)")
        }
    }

    func testEveryPrimaryContentItemHasCitation() throws {
        let content = try ContentRepository.load(from: .main)

        XCTAssertTrue(content.works.allSatisfy { !$0.citations.isEmpty })
        XCTAssertTrue(content.topics.allSatisfy { !$0.citations.isEmpty })
        XCTAssertTrue(content.routes.allSatisfy { !$0.citations.isEmpty })
        XCTAssertTrue(content.audioStops.allSatisfy { !$0.citations.isEmpty })
    }

    func testRoutesReferenceExistingAudioStops() throws {
        let content = try ContentRepository.load(from: .main)
        let stopIDs = Set(content.audioStops.map(\.id))

        for route in content.routes {
            XCTAssertFalse(route.stopIDs.isEmpty)
            for stopID in route.stopIDs {
                XCTAssertTrue(stopIDs.contains(stopID), "Route \(route.id) references missing stop \(stopID)")
            }
        }
    }

    func testMergedPopulationRecordsArePresent() throws {
        let content = try ContentRepository.load(from: .main)

        XCTAssertEqual(content.source(id: "P01")?.localFilename, "musee-rodin-annual-report-2024.pdf")
        XCTAssertNotNil(content.sourceChunks.first { $0.id == "chunk-annual-report-2024" })
        XCTAssertEqual(content.topic(id: "topic-visitor-practical")?.title.en, "Visitor Context")

        let visitRoute = try XCTUnwrap(content.route(id: "route-visit-context"))
        XCTAssertEqual(visitRoute.stopIDs, [
            "stop-visitor-planning",
            "stop-hotel-biron",
            "stop-garden",
            "stop-meudon",
            "stop-education-studio",
            "stop-antiques-collection"
        ])

        XCTAssertTrue(content.audioStop(id: "stop-garden")?.routeIDs.contains("route-visit-context") == true)
        XCTAssertTrue(content.audioStop(id: "stop-drawings")?.routeIDs.contains("route-researcher") == true)
    }
}

final class UserStateModelTests: XCTestCase {
    func testSwiftDataUserStatePersistsInMemory() throws {
        let schema = Schema(AppSchema.userModels)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        let note = ReadingNote(linkedKind: .work, linkedID: "work-le-penseur", title: "Look again", body: "Notice the relation to the Gates.")
        let favorite = FavoriteRecord(linkedKind: .work, linkedID: "work-le-penseur")
        let seen = SeenRecord(workID: "work-le-penseur")
        let route = RouteProgressRecord(routeID: "route-highlights", currentStopID: "stop-le-penseur", completedStopIDs: ["stop-le-penseur"])
        let playback = PlaybackProgressRecord(routeID: "route-highlights", stopID: "stop-le-penseur", state: .paused)

        context.insert(note)
        context.insert(favorite)
        context.insert(seen)
        context.insert(route)
        context.insert(playback)
        try context.save()

        XCTAssertEqual(try context.fetch(FetchDescriptor<ReadingNote>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<FavoriteRecord>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<SeenRecord>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<RouteProgressRecord>()).first?.completedStopIDs, ["stop-le-penseur"])
        XCTAssertEqual(try context.fetch(FetchDescriptor<PlaybackProgressRecord>()).first?.state, .paused)
    }
}

final class SearchAndNarrationTests: XCTestCase {
    func testSearchFindsWorksTopicsRoutesAndNotes() throws {
        let content = try ContentRepository.load(from: .main)
        let note = ReadingNote(linkedKind: .work, linkedID: "work-le-penseur", title: "Garden memory", body: "The garden changed the scale.")

        let rodinResults = SearchService.search("Rodin", content: content, notes: [note], language: .en)
        XCTAssertTrue(rodinResults.contains { $0.kind == .work })

        let gardenResults = SearchService.search("garden", content: content, notes: [note], language: .en)
        XCTAssertTrue(gardenResults.contains { $0.kind == .topic })
        XCTAssertTrue(gardenResults.contains { $0.kind == .route })
        XCTAssertTrue(gardenResults.contains { $0.kind == .note })
    }

    func testSearchFindsMergedPopulationRecords() throws {
        let content = try ContentRepository.load(from: .main)

        let studioResults = SearchService.search("Studio Rodin", content: content, notes: [], language: .en)
        XCTAssertTrue(studioResults.contains { $0.kind == .topic && $0.linkedID == "topic-education-studio" })

        let visitorResults = SearchService.search("visitor", content: content, notes: [], language: .en)
        XCTAssertTrue(visitorResults.contains { $0.kind == .topic && $0.linkedID == "topic-visitor-practical" })
        XCTAssertTrue(visitorResults.contains { $0.kind == .route && $0.linkedID == "route-visit-context" })

        let researchResourcesResults = SearchService.search("research resources", content: content, notes: [], language: .en)
        XCTAssertTrue(researchResourcesResults.contains { $0.kind == .topic && $0.linkedID == "topic-research-resources" })

        let researcherRouteResults = SearchService.search("research infrastructure", content: content, notes: [], language: .en)
        XCTAssertTrue(researcherRouteResults.contains { $0.kind == .route && $0.linkedID == "route-researcher" })

        let moralRightsResults = SearchService.search("moral rights", content: content, notes: [], language: .en)
        XCTAssertTrue(moralRightsResults.contains { $0.kind == .route && $0.linkedID == "route-bronze-editions" })
    }

    func testNarrationStateMachineTransitions() {
        var machine = NarrationStateMachine()

        machine.handle(.play(stopID: "stop-le-penseur"))
        XCTAssertEqual(machine.state, .speaking)
        XCTAssertEqual(machine.currentStopID, "stop-le-penseur")

        machine.handle(.pause)
        XCTAssertEqual(machine.state, .paused)

        machine.handle(.resume)
        XCTAssertEqual(machine.state, .speaking)

        machine.handle(.complete)
        XCTAssertEqual(machine.state, .completed)

        machine.handle(.stop)
        XCTAssertEqual(machine.state, .stopped)
    }
}
