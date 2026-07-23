import XCTest

@MainActor
class BaseRobot {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    @discardableResult
    func assertExists(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) -> Self {
        XCTAssertTrue(element.waitForExistence(timeout: 5), file: file, line: line)
        return self
    }

    @discardableResult
    func tapTab(_ label: String) -> Self {
        let tabButton = app.tabBars.buttons[label]
        if tabButton.waitForExistence(timeout: 2) {
            tabButton.tap()
            return self
        }

        let button = app.buttons["sidebar.\(label.lowercased())"]
        assertExists(button)
        button.tap()
        return self
    }
}
