//
//  NewsListView.swift
//  FinalProject
//

import SwiftUI

/// Latest space news from the Spaceflight News API.
struct NewsListView: View {
    let viewModel: NewsViewModel

    var body: some View {
        List {
            ForEach(viewModel.articles) { article in
                Link(destination: article.url) {
                    NewsRow(article: article)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.isLoading && viewModel.articles.isEmpty {
                ProgressView("Loading news…")
            } else if let message = viewModel.errorMessage, viewModel.articles.isEmpty {
                ContentUnavailableView("Couldn't load news",
                                       systemImage: "wifi.exclamationmark",
                                       description: Text(message))
            }
        }
        .refreshable {
            await viewModel.load()
        }
        .task {
            if viewModel.articles.isEmpty {
                await viewModel.load()
            }
        }
    }
}

/// One news article with its image, source and date.
struct NewsRow: View {
    let article: NewsArticle

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: article.imageUrl) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.secondary.opacity(0.2)
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(3)
                Text("\(article.newsSite) · \(article.publishedAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
