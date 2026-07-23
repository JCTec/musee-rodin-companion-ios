import XCTest

final class PathsRobot: BaseRobot {
    @discardableResult
    func assertVisible() -> Self {
        XCTAssertTrue(app.navigationBars["Paths"].waitForExistence(timeout: 5))
        return self
    }

    @discardableResult
    func assertA11yReady() -> Self {
        XCTAssertTrue(app.staticTexts["Paths"].exists)
        return self
    }

    func openHighlights() -> PathDetailRobot {
        app.cells.containing(.staticText, identifier: "Highlights").firstMatch.tap()
        return PathDetailRobot(app: app).assertVisible()
    }

    func openVisitContext() -> PathDetailRobot {
        let identifier = "path.row.route-visit-context"
        for _ in 0..<5 {
            let button = app.buttons[identifier].firstMatch
            if button.exists {
                button.tap()
                return PathDetailRobot(app: app).assertVisible()
            }

            let cell = app.cells[identifier].firstMatch
            if cell.exists {
                cell.tap()
                return PathDetailRobot(app: app).assertVisible()
            }

            app.swipeUp()
        }

        XCTFail("Could not find Visit Context route")
        return PathDetailRobot(app: app)
    }
}

final class PathDetailRobot: BaseRobot {
    @discardableResult
    func assertVisible() -> Self {
        XCTAssertTrue(app.buttons["readAloud.button"].firstMatch.waitForExistence(timeout: 5))
        return self
    }

    @discardableResult
    func assertA11yReady() -> Self {
        XCTAssertTrue(app.buttons["readAloud.stopButton"].firstMatch.exists)
        XCTAssertTrue(app.buttons.matching(identifier: "path.stop.itemButton.stop-visitor-planning").firstMatch.exists || app.buttons.matching(identifier: "path.stop.itemButton.stop-le-penseur").firstMatch.exists)
        return self
    }

    @discardableResult
    func controlSpeech() -> Self {
        let button = app.buttons["readAloud.button"].firstMatch
        button.tap()
        button.tap()
        app.buttons["readAloud.stopButton"].firstMatch.tap()
        return self
    }

    func openLinkedItem(stopID: String) -> WorkDetailRobot {
        let button = app.buttons["path.stop.itemButton.\(stopID)"].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.tap()
        return WorkDetailRobot(app: app).assertVisible()
    }
}
