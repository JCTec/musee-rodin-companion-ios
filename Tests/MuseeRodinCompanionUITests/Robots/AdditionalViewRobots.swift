import XCTest

final class RootViewRobot: BaseRobot {
    @discardableResult
    func assertVisible() -> Self {
        XCTAssertTrue(app.navigationBars["Places"].waitForExistence(timeout: 5) || app.buttons["sidebar.places"].waitForExistence(timeout: 5))
        return self
    }

    @discardableResult
    func assertA11yReady() -> Self {
        XCTAssertTrue(app.buttons["Places"].exists || app.buttons["sidebar.places"].exists)
        return self
    }
}

final class PlaceholderPanelRobot: BaseRobot {
    @discardableResult
    func assertVisible(label: String) -> Self {
        XCTAssertTrue(app.descendants(matching: .any)[label].waitForExistence(timeout: 5))
        return self
    }

    @discardableResult
    func assertA11yReady(label: String) -> Self {
        XCTAssertTrue(app.descendants(matching: .any)[label].exists)
        return self
    }
}

final class WorkArtworkImageRobot: BaseRobot {
    @discardableResult
    func assertVisible(id: String) -> Self {
        XCTAssertTrue(app.buttons["work.image.\(id)"].waitForExistence(timeout: 5) || app.descendants(matching: .any)["work.image.\(id)"].waitForExistence(timeout: 5))
        return self
    }

    @discardableResult
    func assertA11yReady(id: String) -> Self {
        let image = app.buttons["work.image.\(id)"].exists ? app.buttons["work.image.\(id)"] : app.descendants(matching: .any)["work.image.\(id)"]
        XCTAssertTrue(image.exists)
        XCTAssertFalse(image.label.isEmpty)
        return self
    }

    func openFullScreen(id: String) -> FullScreenArtworkRobot {
        app.swipeDown()
        app.buttons["work.image.\(id)"].tap()
        return FullScreenArtworkRobot(app: app)
    }
}

final class FullScreenArtworkRobot: BaseRobot {
    @discardableResult
    func assertVisible(id: String) -> Self {
        let closeButton = app.buttons["work.fullScreenImage.closeButton"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["work.fullScreenImage.image.\(id)"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["work.fullScreenImage.title.\(id)"].exists)
        return self
    }

    @discardableResult
    func assertA11yReady(id: String) -> Self {
        let closeButton = app.buttons["work.fullScreenImage.closeButton"]
        XCTAssertTrue(closeButton.exists)
        XCTAssertFalse(closeButton.label.isEmpty)
        XCTAssertTrue(app.descendants(matching: .any)["work.fullScreenImage.image.\(id)"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["work.fullScreenImage.title.\(id)"].exists)
        return self
    }

    @discardableResult
    func close() -> Self {
        app.buttons["work.fullScreenImage.closeButton"].tap()
        return self
    }
}

final class CitationChipRobot: BaseRobot {
    @discardableResult
    func assertVisible(id: String) -> Self {
        XCTAssertTrue(app.descendants(matching: .any)["citation.\(id)"].waitForExistence(timeout: 5))
        return self
    }

    @discardableResult
    func assertA11yReady(id: String) -> Self {
        let chip = app.descendants(matching: .any)["citation.\(id)"]
        XCTAssertTrue(chip.exists)
        XCTAssertFalse((chip.label).isEmpty)
        return self
    }
}

final class ConfidenceChipRobot: BaseRobot {
    @discardableResult
    func assertVisible(label: String) -> Self {
        XCTAssertTrue(app.staticTexts[label].waitForExistence(timeout: 5))
        return self
    }

    @discardableResult
    func assertA11yReady(label: String) -> Self {
        XCTAssertTrue(app.staticTexts[label].exists || app.descendants(matching: .any)[label].exists)
        return self
    }
}

final class TagChipRobot: BaseRobot {
    @discardableResult
    func assertVisible(title: String) -> Self {
        XCTAssertTrue(app.staticTexts[title].waitForExistence(timeout: 5))
        return self
    }

    @discardableResult
    func assertA11yReady(title: String) -> Self {
        XCTAssertTrue(app.staticTexts[title].exists)
        return self
    }
}

final class MetadataGridRobot: BaseRobot {
    @discardableResult
    func assertVisible(field: String) -> Self {
        XCTAssertTrue(app.staticTexts[field.uppercased()].waitForExistence(timeout: 5))
        return self
    }

    @discardableResult
    func assertA11yReady(field: String) -> Self {
        XCTAssertTrue(app.staticTexts[field.uppercased()].exists)
        return self
    }
}

final class WorkRowRobot: BaseRobot {
    @discardableResult
    func assertVisible(id: String) -> Self {
        XCTAssertTrue(app.buttons["work.row.\(id)"].waitForExistence(timeout: 5) || app.cells["work.row.\(id)"].waitForExistence(timeout: 5))
        return self
    }

    @discardableResult
    func assertA11yReady(id: String) -> Self {
        let button = app.buttons["work.row.\(id)"]
        let cell = app.cells["work.row.\(id)"]
        XCTAssertTrue(button.exists || cell.exists)
        return self
    }
}

final class ReadAloudButtonRobot: BaseRobot {
    @discardableResult
    func assertVisible() -> Self {
        XCTAssertTrue(app.buttons["readAloud.button"].firstMatch.waitForExistence(timeout: 5))
        return self
    }

    @discardableResult
    func assertA11yReady() -> Self {
        let button = app.buttons["readAloud.button"].firstMatch
        XCTAssertTrue(button.exists)
        XCTAssertFalse(button.label.isEmpty)
        XCTAssertFalse(button.value as? String == nil)
        return self
    }

    @discardableResult
    func toggleTwice() -> Self {
        let button = app.buttons["readAloud.button"].firstMatch
        button.tap()
        button.tap()
        return self
    }
}

final class NoteEditorRobot: BaseRobot {
    @discardableResult
    func assertVisible() -> Self {
        XCTAssertTrue(app.textFields["note.titleField"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textViews["note.bodyField"].exists)
        return self
    }

    @discardableResult
    func assertA11yReady() -> Self {
        XCTAssertTrue(app.buttons["note.saveButton"].exists)
        return self
    }

    @discardableResult
    func fill(title: String, body: String) -> Self {
        let titleField = app.textFields["note.titleField"]
        titleField.tap()
        titleField.typeText(title)
        let bodyField = app.textViews["note.bodyField"]
        bodyField.tap()
        bodyField.typeText(body)
        return self
    }

    func saveToNotes() -> NotesRobot {
        app.buttons["note.saveButton"].tap()
        tapTab("Notes")
        return NotesRobot(app: app).assertVisible()
    }
}

final class TopicDetailRobot: BaseRobot {
    @discardableResult
    func assertVisible() -> Self {
        XCTAssertTrue(app.collectionViews["topicDetail.view"].waitForExistence(timeout: 5) || app.staticTexts["Research note"].waitForExistence(timeout: 5))
        return self
    }

    @discardableResult
    func assertA11yReady() -> Self {
        XCTAssertTrue(app.staticTexts["Related works"].exists || app.staticTexts["Sources"].exists)
        return self
    }
}
