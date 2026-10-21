//
//  QuickLogView.swift
//  FinalProject
//

import SwiftUI

/// Voice or text entry that opens the normal observation form for confirmation.
struct QuickLogView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = QuickLogViewModel()

    var body: some View {
        if let draft = viewModel.draft {
            ObservationFormView(draft: draft)
        } else {
            NavigationStack {
                Form {
                    Section("What did you see?") {
                        TextField("Saw Jupiter and two moons last night around 11…",
                                  text: $viewModel.description,
                                  axis: .vertical)
                            .lineLimit(4...8)
                        Button {
                            if viewModel.isRecording {
                                viewModel.stopRecording()
                            } else {
                                Task { await viewModel.startRecording() }
                            }
                        } label: {
                            Label(viewModel.isRecording ? "Stop recording" : "Speak observation",
                                  systemImage: viewModel.isRecording ? "stop.circle" : "mic")
                        }
                        .disabled(viewModel.isStartingRecording || viewModel.isProcessing)
                        if viewModel.isStartingRecording {
                            ProgressView("Starting microphone…")
                        }
                    }

                    Section {
                        Text("Gemini prepares a draft from your words. Review and edit it before saving.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    if let message = viewModel.errorMessage {
                        Text(message)
                            .foregroundStyle(.red)
                    }
                }
                .navigationTitle("Quick log")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Review") {
                            Task { await viewModel.prepareDraft() }
                        }
                        .disabled(viewModel.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                  viewModel.isProcessing || viewModel.isStartingRecording)
                    }
                }
                .overlay {
                    if viewModel.isProcessing {
                        ProgressView("Preparing observation…")
                    }
                }
                .onDisappear {
                    viewModel.stopRecording()
                }
            }
        }
    }
}
