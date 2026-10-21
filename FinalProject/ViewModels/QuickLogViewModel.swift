//
//  QuickLogViewModel.swift
//  FinalProject
//

import Foundation
import Observation

/// Turns a spoken or typed description into an editable observation draft.
@MainActor
@Observable
final class QuickLogViewModel {
    var description = ""
    var isStartingRecording = false
    var isRecording = false
    var isProcessing = false
    var errorMessage: String?
    var draft: ObservationDraft?

    @ObservationIgnored private let geminiService = GeminiService()
    @ObservationIgnored private let speechService = SpeechService()
    @ObservationIgnored private var recordingRequestID = UUID()

    func startRecording() async {
        guard !isStartingRecording, !isRecording else { return }
        let requestID = UUID()
        recordingRequestID = requestID
        isStartingRecording = true
        errorMessage = nil
        defer { isStartingRecording = false }
        do {
            try await speechService.start { [weak self] transcript in
                self?.description = transcript
            } onFinish: { [weak self] in
                self?.stopRecording()
            } onError: { [weak self] message in
                self?.stopRecording()
                self?.errorMessage = message
            }
            guard recordingRequestID == requestID else {
                speechService.stop()
                return
            }
            isRecording = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func stopRecording() {
        recordingRequestID = UUID()
        speechService.stop()
        isRecording = false
    }

    func prepareDraft() async {
        let input = description.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else {
            errorMessage = "Describe what you observed first."
            return
        }
        stopRecording()
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }

        do {
            let json = try await geminiService.observationJSON(from: input)
            draft = try parseDraft(from: json, originalDescription: input)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func parseDraft(from json: String, originalDescription: String) throws -> ObservationDraft {
        let payload: GeminiObservationPayload
        do {
            payload = try JSONDecoder().decode(GeminiObservationPayload.self, from: Data(json.utf8))
        } catch {
            throw QuickLogError.invalidResult
        }

        let title = payload.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, let date = parseDate(payload.date) else {
            throw QuickLogError.invalidResult
        }
        let knownPlanets = ["Mercury", "Venus", "Earth", "Mars", "Jupiter",
                            "Saturn", "Uranus", "Neptune", "Pluto"]
        let planetName = knownPlanets.first {
            $0.caseInsensitiveCompare(payload.planetName ?? "") == .orderedSame
        }
        let notes = payload.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        return ObservationDraft(title: title,
                                date: date,
                                planetName: planetName,
                                rating: min(max(payload.rating, 1), 5),
                                notes: notes.isEmpty ? originalDescription : notes)
    }

    private func parseDate(_ text: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: text) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: text)
    }
}

private struct GeminiObservationPayload: Decodable {
    let title: String
    let date: String
    let planetName: String?
    let rating: Int
    let notes: String
}

private enum QuickLogError: LocalizedError {
    case invalidResult

    var errorDescription: String? {
        "Gemini returned an incomplete log. Try again or use the regular form."
    }
}
