import XCTest

final class WorkDetailRobot: BaseRobot {
    @discardableResult
    func assertVisible() -> Self {
        XCTAssertTrue(app.buttons["work.favoriteButton"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["work.seenButton"].exists)
        return self
    }

    @discardableResult
    func assertA11yReady() -> Self {
        XCTAssertTrue(app.buttons["readAloud.button"].exists)
        XCTAssertTrue(app.buttons["note.addButton"].exists)
        return self
    }

    @discardableResult
    func readAloudPauseResume() -> Self {
        let button = app.buttons["readAloud.button"]
        button.tap()
        button.tap()
        button.tap()
        return self
    }

    @discardableResult
    func favoriteAndMarkSeen() -> Self {
        app.buttons["work.favoriteButton"].tap()
        app.buttons["work.seenButton"].tap()
        return self
    }

    func addNote(title: String, body: String) -> NotesRobot {
        app.buttons["note.addButton"].tap()
        return NoteEditorRobot(app: app)
            .assertVisible()
            .assertA11yReady()
            .fill(title: title, body: body)
            .saveToNotes()
    }

    @discardableResult
    func revealSources() -> Self {
        let sources = app.buttons["Sources"]
        if sources.waitForExistence(timeout: 5) {
            sources.tap()
        }
        return self
    }
}
