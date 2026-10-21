//
//  EventsView.swift
//  FinalProject
//

import SwiftUI

/// Tab 1: upcoming sky events (bundled data) and live space news (API).
struct EventsView: View {
    enum EventsTab: String, CaseIterable, Identifiable {
        case sky = "Sky Events"
        case news = "News"
        case launches = "Launches"
        var id: String { rawValue }
    }

    @State private var viewModel = EventsViewModel()
    @State private var newsViewModel = NewsViewModel()
    @State private var launchesViewModel = LaunchesViewModel()
    @State private var selectedTab: EventsTab = .sky

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Section", selection: $selectedTab) {
                    ForEach(EventsTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                switch selectedTab {
                case .sky:
                    skyEventsList
                case .news:
                    NewsListView(viewModel: newsViewModel)
                case .launches:
                    LaunchesListView(viewModel: launchesViewModel)
                }
            }
            .navigationTitle("Events")
            .navigationDestination(for: SkyEvent.self) { event in
                EventDetailView(event: event)
            }
            .toolbar {
                if selectedTab == .sky {
                    filterMenu
                }
            }
            .task {
                viewModel.loadEvents()
            }
        }
    }

    private var skyEventsList: some View {
        List {
            if let message = viewModel.errorMessage {
                Text(message).foregroundStyle(.red)
            }
            if let next = viewModel.nextEvent {
                NavigationLink(value: next) {
                    NextEventCard(event: next)
                }
                .listRowSeparator(.hidden)
            }
            ForEach(viewModel.upcomingEvents) { event in
                NavigationLink(value: event) {
                    EventRow(event: event)
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.searchText, prompt: "Search sky events")
        .overlay {
            if viewModel.upcomingEvents.isEmpty && viewModel.errorMessage == nil {
                ContentUnavailableView("No upcoming events",
                                       systemImage: "sparkles",
                                       description: Text("Try a different search or filter."))
            }
        }
    }

    private var filterMenu: some View {
        Menu {
            Button("All events") { viewModel.selectedKind = nil }
            ForEach(SkyEvent.Kind.allCases) { kind in
                Button {
                    viewModel.selectedKind = kind
                } label: {
                    Label(kind.label, systemImage: kind.systemImage)
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
    }
}

/// Highlights the soonest event in the current search and filter results.
struct NextEventCard: View {
    let event: SkyEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Next event", systemImage: "sparkles")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tint)
            Text(event.title)
                .font(.headline)
            Text(event.date, format: .dateTime.month(.wide).day().year())
                .font(.subheadline)
            Text(event.daysUntilText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

/// One row in the sky events list.
struct EventRow: View {
    let event: SkyEvent

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.kind.systemImage)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                Text(event.date, format: .dateTime.month(.wide).day().year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(event.daysUntilText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    EventsView()
        .modelContainer(for: [CelestialBody.self, SavedEvent.self, SkyObservation.self], inMemory: true)
}
