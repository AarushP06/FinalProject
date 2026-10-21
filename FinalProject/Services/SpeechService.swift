//
//  SpeechService.swift
//  FinalProject
//

import AVFAudio
import Foundation
import Speech

/// Transcribes one live observation; audio is not saved by the app.
@MainActor
final class SpeechService {
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var hasInputTap = false
    private var isRecording = false

    func start(onTranscript: @escaping @MainActor (String) -> Void,
               onFinish: @escaping @MainActor () -> Void,
               onError: @escaping @MainActor (String) -> Void) async throws {
        guard !isRecording else { return }

        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        guard speechStatus == .authorized else { throw SpeechError.speechPermissionDenied }
        guard await AVAudioApplication.requestRecordPermission() else {
            throw SpeechError.microphonePermissionDenied
        }
        guard let recognizer = SFSpeechRecognizer(locale: .current), recognizer.isAvailable else {
            throw SpeechError.unavailable
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.sampleRate > 0 else { throw SpeechError.unavailable }

        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement)
            try AVAudioSession.sharedInstance().setActive(true)
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                request.append(buffer)
            }
            hasInputTap = true
            recognitionRequest = request
            isRecording = true
            recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor [weak self] in
                    guard let self, self.isRecording else { return }
                    if let result {
                        onTranscript(result.bestTranscription.formattedString)
                    }
                    if let error {
                        self.stop()
                        onError(error.localizedDescription)
                    } else if result?.isFinal == true {
                        self.stop()
                        onFinish()
                    }
                }
            }
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            stop()
            throw SpeechError.audioFailed
        }
    }

    func stop() {
        isRecording = false
        audioEngine.stop()
        if hasInputTap {
            audioEngine.inputNode.removeTap(onBus: 0)
            hasInputTap = false
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

enum SpeechError: LocalizedError {
    case speechPermissionDenied
    case microphonePermissionDenied
    case unavailable
    case audioFailed

    var errorDescription: String? {
        switch self {
        case .speechPermissionDenied:
            return "Allow Speech Recognition in Settings, or type your log instead."
        case .microphonePermissionDenied:
            return "Allow microphone access in Settings, or type your log instead."
        case .unavailable:
            return "Speech recognition is unavailable. You can type your log instead."
        case .audioFailed:
            return "Couldn't start recording. Try again or type your log."
        }
    }
}
