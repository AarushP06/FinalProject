//
//  NewsArticle.swift
//  FinalProject
//

import Foundation

/// Response from the Spaceflight News API (https://api.spaceflightnewsapi.net/v4/articles/).
struct NewsResponse: Decodable {
    let results: [NewsArticle]
}

/// One news article. Keys arrive in snake_case and are converted by the decoder.
struct NewsArticle: Decodable, Identifiable, Hashable {
    let id: Int
    let title: String
    let url: URL
    let imageUrl: URL?
    let newsSite: String
    let summary: String
    let publishedAt: Date
}
