//
//  EventDetailViewModel.swift
//  FinalProject
//

import Foundation
import Observation

/// Loads news related to one sky event.
@MainActor
@Observable
final class EventDetailViewModel {
    var articles: [NewsArticle] = []
    var isLoading = false
    var errorMessage: String?

    private let newsService = SpaceNewsService()

    func loadRelatedNews(for event: SkyEvent) async {
        isLoading = true
        errorMessage = nil
        articles = []
        defer { isLoading = false }

        do {
            let results = try await newsService.fetchLatest(limit: 3,
                                                            search: searchKeyword(for: event))
            guard !Task.isCancelled else { return }
            articles = Array(results.prefix(3))
        } catch {
            guard !Task.isCancelled else { return }
            errorMessage = error.localizedDescription
        }
    }

    private func searchKeyword(for event: SkyEvent) -> String {
        switch event.kind {
        case .solarEclipse, .lunarEclipse:
            return "eclipse"
        case .meteorShower:
            return "meteor"
        case .planetary:
            return "planet"
        }
    }
}
