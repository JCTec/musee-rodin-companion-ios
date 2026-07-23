import SwiftData
import SwiftUI

@main
struct MuseeRodinCompanionApp: App {
    @StateObject private var contentStore = AppContentStore()
    @StateObject private var narrator = NarrationController()

    private let modelContainer: ModelContainer

    init() {
        let schema = Schema(AppSchema.userModels)
        let isUITest = ProcessInfo.processInfo.arguments.contains("-UITestMode")
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isUITest)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(contentStore)
                .environmentObject(narrator)
                .modelContainer(modelContainer)
                .onAppear {
                    contentStore.load()
                }
        }
    }
}

