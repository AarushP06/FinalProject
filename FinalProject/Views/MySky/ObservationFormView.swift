//
//  ObservationFormView.swift
//  FinalProject
//

import SwiftUI
import SwiftData

/// Sheet for creating a new observation or editing an existing one.
struct ObservationFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CelestialBody.order) private var bodies: [CelestialBody]
    @Query(sort: \SavedEvent.date) private var savedEvents: [SavedEvent]

    @State private var viewModel = MySkyViewModel()

    private let existing: SkyObservation?
    @State private var title: String
    @State private var date: Date
    @State private var notes: String
    @State private var rating: Int
    @State private var selectedBody: CelestialBody?
    @State private var selectedEvent: SavedEvent?

    init(observation: SkyObservation? = nil,
         prefilledBody: CelestialBody? = nil,
         prefilledEvent: SavedEvent? = nil) {
        existing = observation
        _title = State(initialValue: observation?.title ?? "")
        _date = State(initialValue: observation?.date ?? .now)
        _notes = State(initialValue: observation?.notes ?? "")
        _rating = State(initialValue: observation?.rating ?? 3)
        _selectedBody = State(initialValue: observation?.celestialBody ?? prefilledBody)
        _selectedEvent = State(initialValue: observation?.event ?? prefilledEvent)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Observation") {
                    TextField("Title (e.g. Saw Jupiter's moons)", text: $title)
                    DatePicker("Date", selection: $date)
                    Stepper("Rating: \(rating)/5", value: $rating, in: 1...5)
                }

                Section("Linked to") {
                    Picker("Planet", selection: $selectedBody) {
                        Text("None").tag(CelestialBody?.none)
                        ForEach(bodies) { planet in
                            Text(planet.name).tag(Optional(planet))
                        }
                    }
                    Picker("Event", selection: $selectedEvent) {
                        Text("None").tag(SavedEvent?.none)
                        ForEach(savedEvents) { saved in
                            Text(saved.title).tag(Optional(saved))
                        }
                    }
                }

                Section("Notes") {
                    TextField("What did you see?", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                }

                // TODO (Prompt 8): photo picker and current location.

                if let message = viewModel.errorMessage {
                    Text(message).foregroundStyle(.red)
                }
            }
            .navigationTitle(existing == nil ? "New Observation" : "Edit Observation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        viewModel.saveObservation(existing: existing,
                                  title: title,
                                  date: date,
                                  notes: notes,
                                  rating: rating,
                                  celestialBody: selectedBody,
                                  event: selectedEvent,
                                  context: context)
        if viewModel.errorMessage == nil {
            dismiss()
        }
    }
}
