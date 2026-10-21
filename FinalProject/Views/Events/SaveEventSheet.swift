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
            }
            .navigationTitle("Save Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveEvent(event,
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
