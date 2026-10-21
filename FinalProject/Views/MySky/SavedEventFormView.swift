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
    @State private var isSaving = false
    @State private var isAddingToCalendar = false
    @State private var activeAlert: FormAlert?

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
                Section {
                    Button {
                        addToCalendar()
                    } label: {
                        Label("Add to Calendar", systemImage: "calendar.badge.plus")
                    }
                    .disabled(viewModel.calendarAdded)
                }
                if !savedEvent.observations.isEmpty {
                    Section("Observations") {
                        ForEach(savedEvent.observations) { observation in
                            ObservationRow(observation: observation)
                        }
                    }
                }
                if let message = viewModel.errorMessage {
                    Text(message).foregroundStyle(.red)
                }
            }
            .disabled(isSaving || isAddingToCalendar)
            .navigationTitle("Saved Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(isSaving || isAddingToCalendar)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                    .disabled(isSaving || isAddingToCalendar)
                }
            }
            .alert(item: $activeAlert) { alert in
                switch alert {
                case .reminder:
                    Alert(title: Text("Reminder unavailable"),
                          message: Text(viewModel.notificationMessage ?? "The event was saved without a reminder."),
                          dismissButton: .default(Text("OK")) { dismiss() })
                case .calendar:
                    Alert(title: Text(viewModel.calendarAdded ? "Added to Calendar" : "Couldn't add to Calendar"),
                          message: Text(viewModel.calendarMessage ?? "Please try again."),
                          dismissButton: .default(Text("OK")))
                }
            }
        }
    }

    private func save() {
        isSaving = true
        Task {
            await viewModel.updateSavedEvent(savedEvent,
                                             notes: notes,
                                             reminderEnabled: reminderEnabled,
                                             context: context)
            isSaving = false
            guard viewModel.errorMessage == nil else { return }
            if viewModel.notificationMessage == nil {
                dismiss()
            } else {
                activeAlert = .reminder
            }
        }
    }

    private func addToCalendar() {
        isAddingToCalendar = true
        Task {
            await viewModel.addToCalendar(savedEvent, notes: notes)
            isAddingToCalendar = false
            activeAlert = .calendar
        }
    }
}

private enum FormAlert: Identifiable {
    case reminder
    case calendar

    var id: Self { self }
}
