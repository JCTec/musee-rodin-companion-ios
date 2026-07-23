import XCTest

final class WorksRobot: BaseRobot {
    @discardableResult
    func assertVisible() -> Self {
        XCTAssertTrue(app.navigationBars["Works"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["works.filter.All"].exists)
        return self
    }

    @discardableResult
    func assertA11yReady() -> Self {
        XCTAssertTrue(app.buttons["works.filter.Rodin"].exists)
        XCTAssertTrue(app.buttons["works.filter.Claudel"].exists)
        return self
    }

    @discardableResult
    func filterClaudel() -> Self {
        app.buttons["works.filter.Claudel"].tap()
        return self
    }

    func openFirstWork() -> WorkDetailRobot {
        let firstCell = app.cells.containing(.staticText, identifier: "The Thinker").firstMatch
        if firstCell.waitForExistence(timeout: 2) {
            firstCell.tap()
        } else {
            app.cells.element(boundBy: 1).tap()
        }
        return WorkDetailRobot(app: app).assertVisible()
    }
}

