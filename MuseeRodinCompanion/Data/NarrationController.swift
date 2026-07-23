@preconcurrency import AVFoundation
import Foundation

enum NarrationEvent {
    case play(stopID: String)
    case pause
    case resume
    case stop
    case complete
}

struct NarrationStateMachine: Equatable {
    private(set) var state: PlaybackState = .idle
    private(set) var currentStopID: String?

    mutating func handle(_ event: NarrationEvent) {
        switch event {
        case .play(let stopID):
            currentStopID = stopID
            state = .speaking
        case .pause:
            if state == .speaking {
                state = .paused
            }
        case .resume:
            if state == .paused {
                state = .speaking
            }
        case .stop:
            state = .stopped
        case .complete:
            state = .completed
        }
    }
}

@MainActor
final class NarrationController: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published private(set) var stateMachine = NarrationStateMachine()
    @Published var rate: Float = AVSpeechUtteranceDefaultSpeechRate

    private let synthesizer = AVSpeechSynthesizer()
    private let isUITestMode = ProcessInfo.processInfo.arguments.contains("-UITestMode")

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func toggle(stop: AudioStop, language: AppLanguage) {
        switch stateMachine.state {
        case .speaking where stateMachine.currentStopID == stop.id:
            pause()
        case .paused where stateMachine.currentStopID == stop.id:
            resume()
        default:
            speak(stop: stop, language: language)
        }
    }

    func speak(stop: AudioStop, language: AppLanguage) {
        if isUITestMode {
            stateMachine.handle(.play(stopID: stop.id))
            return
        }
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: stop.script.value(for: language))
        utterance.voice = AVSpeechSynthesisVoice(language: voiceIdentifier(for: language))
        utterance.rate = rate
        stateMachine.handle(.play(stopID: stop.id))
        synthesizer.speak(utterance)
    }

    func pause() {
        if isUITestMode {
            stateMachine.handle(.pause)
            return
        }
        synthesizer.pauseSpeaking(at: .word)
        stateMachine.handle(.pause)
    }

    func resume() {
        if isUITestMode {
            stateMachine.handle(.resume)
            return
        }
        synthesizer.continueSpeaking()
        stateMachine.handle(.resume)
    }

    func stop() {
        if isUITestMode {
            stateMachine.handle(.stop)
            return
        }
        synthesizer.stopSpeaking(at: .immediate)
        stateMachine.handle(.stop)
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            self?.stateMachine.handle(.complete)
        }
    }

    private func voiceIdentifier(for language: AppLanguage) -> String {
        switch language {
        case .en: "en-US"
        case .fr: "fr-FR"
        case .es: "es-MX"
        }
    }
}
