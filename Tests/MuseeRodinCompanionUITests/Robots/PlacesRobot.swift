import XCTest

final class PlacesRobot: BaseRobot {
    @discardableResult
    func assertVisible() -> Self {
        assertExists(app.collectionViews.firstMatch)
        XCTAssertTrue(app.navigationBars["Places"].waitForExistence(timeout: 5))
        return self
    }

    @discardableResult
    func assertA11yReady() -> Self {
        XCTAssertTrue(findPlaceRow("topic-hotel-biron").exists)
        XCTAssertTrue(findPlaceRow("topic-garden").exists)
        XCTAssertTrue(findPlaceRow("topic-meudon").exists)
        return self
    }

    func goToWorks() -> WorksRobot {
        tapTab("Works")
        return WorksRobot(app: app).assertVisible()
    }

    func goToPaths() -> PathsRobot {
        tapTab("Paths")
        return PathsRobot(app: app).assertVisible()
    }

    func goToSearch() -> SearchRobot {
        tapTab("Search")
        return SearchRobot(app: app).assertVisible()
    }

    func goToNotes() -> NotesRobot {
        tapTab("Notes")
        return NotesRobot(app: app).assertVisible()
    }

    func openHotelBironPlace() -> TopicDetailRobot {
        findPlaceRow("topic-hotel-biron").tap()
        return TopicDetailRobot(app: app).assertVisible()
    }

    func openGardenPlace() -> TopicDetailRobot {
        findPlaceRow("topic-garden").tap()
        return TopicDetailRobot(app: app).assertVisible()
    }

    func openMeudonPlace() -> TopicDetailRobot {
        findPlaceRow("topic-meudon").tap()
        return TopicDetailRobot(app: app).assertVisible()
    }

    private func placeRow(_ topicID: String) -> XCUIElement {
        app.buttons["place.row.\(topicID)"]
    }

    private func findPlaceRow(_ topicID: String) -> XCUIElement {
        let row = placeRow(topicID)
        if row.exists { return row }

        for _ in 0..<4 {
            app.swipeUp()
            if row.waitForExistence(timeout: 1) {
                return row
            }
        }

        for _ in 0..<4 {
            app.swipeDown()
            if row.waitForExistence(timeout: 1) {
                return row
            }
        }

        XCTFail("Could not find place row \(topicID)")
        return row
    }
}
