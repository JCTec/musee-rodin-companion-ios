import XCTest

@MainActor
final class MuseeRodinCompanionUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launchConfiguredApp(extraArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-UITestMode",
            "-ShowcaseData",
            "-AppleLanguages",
            "(en)",
            "-AppleLocale",
            "en_US"
        ] + extraArguments
        app.launch()
        return app
    }

    func testRobotDrivenCoreFlow() {
        let app = launchConfiguredApp()
        let places = PlacesRobot(app: app)
            .assertVisible()
            .assertA11yReady()

        places.goToWorks()
            .assertA11yReady()
            .openFirstWork()
            .assertA11yReady()
            .readAloudPauseResume()
            .favoriteAndMarkSeen()
            .addNote(title: " Robot note", body: "This note was created by the UI robot.")
            .assertA11yReady()
            .assertNoteExists("This note was created by the UI robot.")
    }

    func testRobotDrivenPathsAndSearch() {
        let app = launchConfiguredApp()
        let places = PlacesRobot(app: app)
            .assertVisible()

        let pathDetail = places.goToPaths()
            .assertA11yReady()
            .openHighlights()
            .assertA11yReady()
            .controlSpeech()
            .openLinkedItem(stopID: "stop-le-penseur")
            .assertA11yReady()

        pathDetail.tapTab("Search")
        SearchRobot(app: app)
            .assertVisible()
            .assertA11yReady()
            .search("Balzac")
    }

    func testRobotDrivenMergedPopulationRouteAndSearch() {
        let app = launchConfiguredApp()
        let places = PlacesRobot(app: app)
            .assertVisible()

        let pathDetail = places.goToPaths()
            .assertA11yReady()
            .openVisitContext()
            .assertA11yReady()
            .controlSpeech()

        pathDetail.tapTab("Search")
        SearchRobot(app: app)
            .assertVisible()
            .assertA11yReady()
            .search("visitor")
    }

    func testRobotCoverageForPlaceDetails() {
        let app = launchConfiguredApp()

        RootViewRobot(app: app)
            .assertVisible()
            .assertA11yReady()

        PlacesRobot(app: app)
            .assertVisible()
            .openHotelBironPlace()
            .assertA11yReady()

        PlaceholderPanelRobot(app: app)
            .assertVisible(label: "topic placeholder")
            .assertA11yReady(label: "topic placeholder")

        app.navigationBars.buttons["Places"].tap()

        PlacesRobot(app: app)
            .assertVisible()
            .openGardenPlace()
            .assertA11yReady()

        app.navigationBars.buttons["Places"].tap()

        PlacesRobot(app: app)
            .assertVisible()
            .openMeudonPlace()
            .assertA11yReady()
    }

    func testRobotCoverageForSourceAndReusableViews() {
        let app = launchConfiguredApp()

        PlacesRobot(app: app)
            .assertVisible()
            .goToWorks()
            .assertA11yReady()

        WorkRowRobot(app: app)
            .assertVisible(id: "work-le-penseur")
            .assertA11yReady(id: "work-le-penseur")

        let workDetail = WorksRobot(app: app)
            .openFirstWork()
            .assertA11yReady()

        PlaceholderPanelRobot(app: app)
            .assertVisible(label: "personal photo or rights-cleared image")
            .assertA11yReady(label: "personal photo or rights-cleared image")
        ConfidenceChipRobot(app: app)
            .assertVisible(label: "Verified")
            .assertA11yReady(label: "Verified")
        MetadataGridRobot(app: app)
            .assertVisible(field: "Material")
            .assertA11yReady(field: "Material")
        TagChipRobot(app: app)
            .assertVisible(title: "rodin")
            .assertA11yReady(title: "rodin")
        ReadAloudButtonRobot(app: app)
            .assertVisible()
            .assertA11yReady()
            .toggleTwice()

        workDetail.revealSources()
        CitationChipRobot(app: app)
            .assertVisible(id: "cite-work-le-penseur")
            .assertA11yReady(id: "cite-work-le-penseur")
    }

    func testAccessibilityDisplaySettingsSmoke() {
        let app = launchConfiguredApp(extraArguments: [
            "-AppleInterfaceStyle",
            "Dark",
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityXXXL",
            "-UIAccessibilityDarkerSystemColorsEnabled",
            "YES",
            "-UIAccessibilityReduceMotionEnabled",
            "YES"
        ])

        let places = PlacesRobot(app: app)
            .assertVisible()
            .assertA11yReady()

        places.goToWorks()
            .assertA11yReady()
            .tapTab("Paths")

        PathsRobot(app: app)
            .assertVisible()
            .assertA11yReady()
    }
}
