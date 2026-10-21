//
//  SavedEventFormView.swift
//  FinalProject
//

import SwiftUI
import SwiftData

/// Sheet for editing a saved event's notes and reminder.
struct SavedEventFormView: View {
    let savedEvent: SavedEvent

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = MySkyViewModel()
    @State private var notes: String
    @State private var reminderEnabled: Bool

    init(savedEvent: SavedEvent) {
        self.savedEvent = savedEvent
        _notes = State(initialValue: savedEvent.notes)
        _reminderEnabled = State(initialValue: savedEvent.reminderEnabled)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Event") {
                    Label(savedEvent.title, systemImage: savedEvent.systemImage)
                    Text(savedEvent.date, style: .date)
                        .foregroundStyle(.secondary)
                    Text(savedEvent.visibility)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("Your plan") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                    Toggle("Remind me the day before", isOn: $reminderEnabled)
                }
                // TODO (Prompt 7): "Add to Calendar" button using EventKit.
                if !savedEvent.observations.isEmpty {
                    Section("Observations") {
                        ForEach(savedEvent.observations) { observation in
                            ObservationRow(observation: observation)
                        }
                    }
                }
            }
            .navigationTitle("Saved Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.updateSavedEvent(savedEvent,
                                                   notes: notes,
                                                   reminderEnabled: reminderEnabled,
                                                   context: context)
                        dismiss()
                    }
                }
            }
        }
    }
}
