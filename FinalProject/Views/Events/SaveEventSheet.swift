//
//  SaveEventSheet.swift
//  FinalProject
//

import SwiftUI
import SwiftData

/// Sheet for saving a sky event to My Sky with personal notes.
struct SaveEventSheet: View {
    let event: SkyEvent

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = MySkyViewModel()
    @State private var notes = ""
    @State private var reminderEnabled = true
    @State private var isSaving = false
    @State private var showingReminderAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Event") {
                    Text(event.title)
                    Text(event.date, style: .date)
                        .foregroundStyle(.secondary)
                }
                Section("Your plan") {
                    TextField("Notes (where, who, what to bring)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                    Toggle("Remind me the day before", isOn: $reminderEnabled)
                }
                if let message = viewModel.errorMessage {
                    Text(message).foregroundStyle(.red)
                }
            }
            .disabled(isSaving)
            .navigationTitle("Save Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                    .disabled(isSaving)
                }
            }
            .alert("Reminder unavailable", isPresented: $showingReminderAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text(viewModel.notificationMessage ?? "The event was saved without a reminder.")
            }
        }
    }

    private func save() {
        isSaving = true
        Task {
            await viewModel.saveEvent(event,
                                      notes: notes,
                                      reminderEnabled: reminderEnabled,
                                      context: context)
            isSaving = false
            guard viewModel.errorMessage == nil else { return }
            if viewModel.notificationMessage == nil {
                dismiss()
            } else {
                showingReminderAlert = true
            }
        }
    }
}
