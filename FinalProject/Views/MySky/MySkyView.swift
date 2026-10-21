//
//  MySkyView.swift
//  FinalProject
//

import SwiftUI
import SwiftData

/// Tab 3: the user's own data. Saved events and observations, with full CRUD.
struct MySkyView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \SavedEvent.date) private var savedEvents: [SavedEvent]
    @Query(sort: \SkyObservation.date, order: .reverse) private var observations: [SkyObservation]

    @State private var viewModel = MySkyViewModel()
    @State private var showingNewObservation = false
    @State private var editingObservation: SkyObservation?
    @State private var editingEvent: SavedEvent?

    var body: some View {
        NavigationStack {
            List {
                Section("Saved events") {
                    if savedEvents.isEmpty {
                        Text("Save an event from the Events tab.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(savedEvents) { saved in
                        Button {
                            editingEvent = saved
                        } label: {
                            SavedEventRow(savedEvent: saved)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        offsets.map { savedEvents[$0] }
                            .forEach { viewModel.deleteSavedEvent($0, context: context) }
                    }
                }

                Section("Observations") {
                    if observations.isEmpty {
                        Text("Tap + to log what you saw.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(observations) { observation in
                        Button {
                            editingObservation = observation
                        } label: {
                            ObservationRow(observation: observation)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        offsets.map { observations[$0] }
                            .forEach { viewModel.deleteObservation($0, context: context) }
                    }
                }
            }
            .navigationTitle("My Sky")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewObservation = true
                    } label: {
                        Label("New observation", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewObservation) {
                ObservationFormView()
            }
            .sheet(item: $editingObservation) { observation in
                ObservationFormView(observation: observation)
            }
            .sheet(item: $editingEvent) { saved in
                SavedEventFormView(savedEvent: saved)
            }
        }
    }
}

/// One saved event in the My Sky list.
struct SavedEventRow: View {
    let savedEvent: SavedEvent

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: savedEvent.systemImage)
                .foregroundStyle(.tint)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(savedEvent.title).font(.headline)
                Text(savedEvent.date, format: .dateTime.month(.abbreviated).day().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if savedEvent.reminderEnabled {
                Image(systemName: "bell.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }
}

/// One observation, used in My Sky and on a planet's detail screen.
struct ObservationRow: View {
    let observation: SkyObservation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(observation.title).font(.headline)
            HStack(spacing: 6) {
                Text(observation.date, format: .dateTime.month(.abbreviated).day().year())
                if let planetName = observation.celestialBody?.name {
                    Text("· \(planetName)")
                }
                Spacer()
                Text(String(repeating: "★", count: observation.rating))
                    .foregroundStyle(.yellow)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    MySkyView()
        .modelContainer(for: [CelestialBody.self, SavedEvent.self, SkyObservation.self], inMemory: true)
}
