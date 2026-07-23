import Foundation
import SwiftUI

@MainActor
final class AppContentStore: ObservableObject {
    @Published private(set) var content: ContentRepository
    @Published var language: AppLanguage

    init(content: ContentRepository = .empty, language: AppLanguage = Locale.autodetectedLanguage) {
        self.content = content
        self.language = language
    }

    func load(bundle: Bundle = .main) {
        do {
            content = try ContentRepository.load(from: bundle)
        } catch {
            assertionFailure(error.localizedDescription)
            content = .empty
        }
    }

    static func preview() -> AppContentStore {
        let store = AppContentStore()
        store.load()
        return store
    }
}

extension Locale {
    static var autodetectedLanguage: AppLanguage {
        let code = Locale.current.language.languageCode?.identifier.lowercased()
        return AppLanguage(rawValue: code ?? "") ?? .en
    }
}

