import Foundation
import Combine
import Network
import Speech
import AVFoundation

@MainActor
final class ConnectivityStatus: ObservableObject {
    static let shared = ConnectivityStatus()

    @Published private(set) var isOnline = true
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "YouNew.ConnectivityStatus")

    private init() {
        monitor.pathUpdateHandler = { path in
            let isOnline = path.status == .satisfied
            Task { @MainActor [weak self] in
                self?.isOnline = isOnline
            }
        }
        monitor.start(queue: queue)
    }

    deinit { monitor.cancel() }
}

@MainActor
final class VoiceInputController: ObservableObject {
    enum State: Equatable {
        case idle
        case requestingPermission
        case listening
        case unavailable(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var transcript = ""

    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    var isListening: Bool { state == .listening }

    func toggle(language: AppLanguage) {
        isListening ? stop() : requestPermissionAndStart(language: language)
    }

    func stop() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        if case .unavailable = state { return }
        state = .idle
    }

    private func requestPermissionAndStart(language: AppLanguage) {
        state = .requestingPermission
        Task {
            let speechAuthorized = await requestSpeechAuthorization()
            guard speechAuthorized else {
                state = .unavailable(permissionMessage(language))
                return
            }

            let microphoneAuthorized = await AVAudioApplication.requestRecordPermission()
            guard microphoneAuthorized else {
                state = .unavailable(permissionMessage(language))
                return
            }

            startRecognition(language: language)
        }
    }

    private func requestSpeechAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    private func startRecognition(language: AppLanguage) {
        stop()
        transcript = ""

        let localeID: String
        switch language {
        case .russian: localeID = "ru-RU"
        case .dutch: localeID = "nl-NL"
        case .english: localeID = "en-US"
        }

        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeID)), recognizer.isAvailable else {
            state = .unavailable(unavailableMessage(language))
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            recognitionRequest = request

            let inputNode = audioEngine.inputNode
            let format = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1_024, format: format) { buffer, _ in
                request.append(buffer)
            }
            audioEngine.prepare()
            try audioEngine.start()
            state = .listening

            recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor in
                    if let result {
                        self?.transcript = result.bestTranscription.formattedString
                        if result.isFinal { self?.stop() }
                    } else if error != nil {
                        self?.stop()
                    }
                }
            }
        } catch {
            stop()
            state = .unavailable(unavailableMessage(language))
        }
    }

    private func permissionMessage(_ language: AppLanguage) -> String {
        switch language {
        case .russian: return "Разрешите доступ к микрофону и распознаванию речи в настройках."
        case .dutch: return "Sta microfoon- en spraakherkenning toe in Instellingen."
        case .english: return "Allow microphone and speech recognition access in Settings."
        }
    }

    private func unavailableMessage(_ language: AppLanguage) -> String {
        switch language {
        case .russian: return "Голосовой ввод сейчас недоступен."
        case .dutch: return "Spraakinvoer is momenteel niet beschikbaar."
        case .english: return "Voice input is currently unavailable."
        }
    }
}
