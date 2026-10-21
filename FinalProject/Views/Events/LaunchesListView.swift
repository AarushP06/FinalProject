//
//  LaunchesListView.swift
//  FinalProject
//

import SwiftUI

/// Upcoming launches from Launch Library 2, with cached refreshes.
struct LaunchesListView: View {
    let viewModel: LaunchesViewModel

    var body: some View {
        List {
            if let message = viewModel.errorMessage, !viewModel.launches.isEmpty {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            ForEach(viewModel.launches) { launch in
                LaunchRow(launch: launch)
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.isLoading && viewModel.launches.isEmpty {
                ProgressView("Loading launches…")
            } else if let message = viewModel.errorMessage, viewModel.launches.isEmpty {
                ContentUnavailableView("Couldn't load launches",
                                       systemImage: "wifi.exclamationmark",
                                       description: Text(message))
            } else if viewModel.launches.isEmpty {
                ContentUnavailableView("No upcoming launches", systemImage: "airplane.departure")
            }
        }
        .refreshable { await viewModel.load() }
        .task {
            if viewModel.launches.isEmpty { await viewModel.load() }
        }
    }
}

/// One launch's image, provider, schedule and status.
struct LaunchRow: View {
    let launch: Launch

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: launch.imageURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Image(systemName: "airplane.departure")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.quaternary)
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(launch.name)
                    .font(.headline)
                Text(launch.launchServiceProvider?.name ?? "Provider unknown")
                    .font(.subheadline)
                Text(launch.net, format: .dateTime.month(.abbreviated).day().year().hour().minute())
                    .font(.caption)
                Text(launch.status.name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
