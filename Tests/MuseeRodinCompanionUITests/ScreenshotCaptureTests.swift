import XCTest

@MainActor
final class ScreenshotCaptureTests: XCTestCase {
    private var deviceSlug: String {
        ProcessInfo.processInfo.environment["SCREENSHOT_DEVICE_SLUG"] ?? "simulator"
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCaptureScreenshotMatrix() {
        captureMainDarkFlow()
        captureSearchStates()
        captureAppearanceStates()
    }

    private func captureMainDarkFlow() {
        let app = launchConfiguredApp(appearance: "Dark")

        PlacesRobot(app: app)
            .assertVisible()
            .assertA11yReady()
        capture(app, view: "places", state: "list", appearance: "dark")

        PlacesRobot(app: app).openHotelBironPlace().assertA11yReady()
        capture(app, view: "places", state: "hotel_biron_detail", appearance: "dark")
        tapBack(to: "Places", in: app)

        PlacesRobot(app: app).openGardenPlace().assertA11yReady()
        capture(app, view: "places", state: "garden_detail", appearance: "dark")
        tapBack(to: "Places", in: app)

        PlacesRobot(app: app).openMeudonPlace().assertA11yReady()
        capture(app, view: "places", state: "meudon_detail", appearance: "dark")
        tapBack(to: "Places", in: app)

        tapTab("Notes", in: app)
        NotesRobot(app: app).assertVisible().assertA11yReady()
        capture(app, view: "notes", state: "empty", appearance: "dark")
        app.buttons["note.addButton"].tap()
        XCTAssertTrue(app.textFields["note.titleField"].waitForExistence(timeout: 5))
        capture(app, view: "notes", state: "editor", appearance: "dark")
        app.buttons["Cancel"].tap()

        tapTab("Works", in: app)
        WorksRobot(app: app).assertVisible().assertA11yReady()
        capture(app, view: "works", state: "all_filter", appearance: "dark")

        app.buttons["works.filter.Rodin"].tap()
        capture(app, view: "works", state: "rodin_filter", appearance: "dark")

        app.buttons["works.filter.Claudel"].tap()
        capture(app, view: "works", state: "claudel_filter", appearance: "dark")

        app.buttons["works.filter.All"].tap()
        searchFirstField(in: app, text: "Thinker")
        capture(app, view: "works", state: "search_thinker", appearance: "dark")

        openWork(title: "The Thinker", in: app)
        WorkDetailRobot(app: app).assertVisible().assertA11yReady()
        capture(app, view: "works", state: "work_detail_default", appearance: "dark")

        tapButton("Research note", in: app)
        capture(app, view: "works", state: "work_detail_research_note_expanded", appearance: "dark")

        tapButton("Sources", in: app)
        capture(app, view: "works", state: "work_detail_sources_expanded", appearance: "dark")

        tapIdentifier("work.favoriteButton", in: app)
        tapIdentifier("work.seenButton", in: app)
        capture(app, view: "works", state: "work_detail_favorited_seen", appearance: "dark")

        tapIdentifier("note.addButton", in: app)
        XCTAssertTrue(app.textFields["note.titleField"].waitForExistence(timeout: 5))
        app.textViews["note.bodyField"].tap()
        app.textViews["note.bodyField"].typeText("Screenshot matrix note.")
        app.buttons["note.saveButton"].tap()

        tapTab("Notes", in: app)
        NotesRobot(app: app).assertVisible()
        capture(app, view: "notes", state: "saved_note", appearance: "dark")
        app.buttons["Favorites"].tap()
        capture(app, view: "notes", state: "favorites", appearance: "dark")
        app.buttons["Seen"].tap()
        capture(app, view: "notes", state: "seen", appearance: "dark")

        tapTab("Paths", in: app)
        PathsRobot(app: app).assertVisible().assertA11yReady()
        capture(app, view: "paths", state: "list", appearance: "dark")

        PathsRobot(app: app).openHighlights().assertA11yReady()
        capture(app, view: "paths", state: "highlights_detail_idle", appearance: "dark")

        let readAloud = app.buttons["readAloud.button"].firstMatch
        XCTAssertTrue(readAloud.waitForExistence(timeout: 5))
        readAloud.tap()
        waitForAnimations()
        capture(app, view: "paths", state: "read_aloud_playing", appearance: "dark")

        readAloud.tap()
        waitForAnimations()
        capture(app, view: "paths", state: "read_aloud_paused", appearance: "dark")

        app.buttons["readAloud.stopButton"].tap()
        tapIdentifier("path.stop.itemButton.stop-le-penseur", in: app)
        WorkDetailRobot(app: app).assertVisible()
        capture(app, view: "paths", state: "linked_work_detail", appearance: "dark")

        app.terminate()
    }

    private func captureSearchStates() {
        let app = launchConfiguredApp(appearance: "Dark")
        tapTab("Search", in: app)
        SearchRobot(app: app).assertVisible().assertA11yReady()
        capture(app, view: "search", state: "empty", appearance: "dark")

        searchFirstField(in: app, text: "Balzac")
        capture(app, view: "search", state: "work_results", appearance: "dark")
        app.terminate()

        let pathApp = launchConfiguredApp(appearance: "Dark")
        tapTab("Search", in: pathApp)
        searchFirstField(in: pathApp, text: "visitor")
        capture(pathApp, view: "search", state: "path_topic_results", appearance: "dark")
        pathApp.terminate()

        let noResultsApp = launchConfiguredApp(appearance: "Dark")
        tapTab("Search", in: noResultsApp)
        searchFirstField(in: noResultsApp, text: "zzzzzzzz")
        capture(noResultsApp, view: "search", state: "no_results", appearance: "dark")
        noResultsApp.terminate()
    }

    private func captureAppearanceStates() {
        let lightApp = launchConfiguredApp(appearance: "Light")
        PlacesRobot(app: lightApp).assertVisible()
        capture(lightApp, view: "places", state: "list", appearance: "light")
        lightApp.terminate()

        let accessibilityApp = launchConfiguredApp(appearance: "Dark", extraArguments: [
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityXXXL",
            "-UIAccessibilityDarkerSystemColorsEnabled",
            "YES",
            "-UIAccessibilityReduceMotionEnabled",
            "YES"
        ])
        PlacesRobot(app: accessibilityApp).assertVisible().assertA11yReady()
        capture(accessibilityApp, view: "places", state: "accessibility_large_text", appearance: "dark")
        tapTab("Paths", in: accessibilityApp)
        PathsRobot(app: accessibilityApp).assertVisible()
        capture(accessibilityApp, view: "paths", state: "accessibility_large_text", appearance: "dark")
        accessibilityApp.terminate()
    }

    private func launchConfiguredApp(appearance: String, extraArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-UITestMode",
            "-ShowcaseData",
            "-AppleLanguages",
            "(en)",
            "-AppleLocale",
            "en_US",
            "-AppleInterfaceStyle",
            appearance
        ] + extraArguments
        app.launch()
        return app
    }

    private func capture(_ app: XCUIApplication, view: String, state: String, appearance: String) {
        waitForAnimations()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))

        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "\(deviceSlug)__\(view)__\(state)__\(appearance)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func tapTab(_ label: String, in app: XCUIApplication) {
        let tabButton = app.tabBars.buttons[label]
        if tabButton.waitForExistence(timeout: 2) {
            tabButton.tap()
            return
        }

        let sidebarButton = app.buttons["sidebar.\(label.lowercased())"]
        XCTAssertTrue(sidebarButton.waitForExistence(timeout: 5))
        sidebarButton.tap()
    }

    private func tapBack(to label: String, in app: XCUIApplication) {
        let button = app.navigationBars.buttons[label]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.tap()
    }

    private func searchFirstField(in app: XCUIApplication, text: String) {
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(text)
        waitForAnimations()
    }

    private func openWork(title: String, in app: XCUIApplication) {
        let cell = app.cells.containing(.staticText, identifier: title).firstMatch
        if cell.waitForExistence(timeout: 5) {
            cell.tap()
            return
        }

        let text = app.staticTexts[title]
        XCTAssertTrue(text.waitForExistence(timeout: 5))
        text.tap()
    }

    private func tapButton(_ label: String, in app: XCUIApplication) {
        let button = findElement(app.buttons[label], in: app)
        XCTAssertTrue(button.exists)
        button.tap()
    }

    private func tapIdentifier(_ identifier: String, in app: XCUIApplication) {
        let button = findElement(app.buttons[identifier].firstMatch, in: app)
        XCTAssertTrue(button.exists)
        button.tap()
    }

    private func findElement(_ element: XCUIElement, in app: XCUIApplication) -> XCUIElement {
        if element.exists { return element }

        for _ in 0..<6 {
            app.swipeUp()
            if element.waitForExistence(timeout: 1) {
                return element
            }
        }

        for _ in 0..<6 {
            app.swipeDown()
            if element.waitForExistence(timeout: 1) {
                return element
            }
        }

        return element
    }

    private func waitForAnimations() {
        RunLoop.current.run(until: Date().addingTimeInterval(0.7))
    }
}
