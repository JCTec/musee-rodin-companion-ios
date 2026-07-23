import XCTest

final class SearchRobot: BaseRobot {
    @discardableResult
    func assertVisible() -> Self {
        XCTAssertTrue(app.navigationBars["Search"].waitForExistence(timeout: 5))
        return self
    }

    @discardableResult
    func assertA11yReady() -> Self {
        XCTAssertTrue(app.searchFields.firstMatch.exists || app.staticTexts["Search the app"].exists)
        return self
    }

    @discardableResult
    func search(_ text: String) -> Self {
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(text)
        XCTAssertTrue(app.staticTexts[text].waitForExistence(timeout: 1) || app.cells.firstMatch.waitForExistence(timeout: 5))
        return self
    }
}
