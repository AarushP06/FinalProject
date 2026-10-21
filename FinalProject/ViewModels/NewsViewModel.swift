//
//  NewsViewModel.swift
//  FinalProject
//

import Foundation
import Observation

/// Loads space news for the News section of the Events tab.
@Observable
final class NewsViewModel {
    var articles: [NewsArticle] = []
    var isLoading = false
    var errorMessage: String?

    private let service = SpaceNewsService()

    /// Runs on the main actor so the UI updates safely; the network call itself
    /// is awaited, so it never blocks the main thread.
    @MainActor
    func load(search: String? = nil) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            articles = try await service.fetchLatest(search: search)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
