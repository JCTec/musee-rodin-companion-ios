import XCTest

final class NotesRobot: BaseRobot {
    @discardableResult
    func assertVisible() -> Self {
        XCTAssertTrue(app.navigationBars["Notes"].waitForExistence(timeout: 5))
        return self
    }

    @discardableResult
    func assertA11yReady() -> Self {
        XCTAssertTrue(app.buttons["Notes"].exists || app.staticTexts["Notes"].exists)
        return self
    }

    @discardableResult
    func assertNoteExists(_ text: String) -> Self {
        XCTAssertTrue(app.staticTexts[text].waitForExistence(timeout: 5))
        return self
    }
}

