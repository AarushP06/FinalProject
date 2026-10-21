//
//  EventDetailView.swift
//  FinalProject
//

import SwiftUI
import SwiftData

/// Insights for one sky event, with a button to save it to My Sky.
struct EventDetailView: View {
    let event: SkyEvent

    @Query private var savedEvents: [SavedEvent]
    @State private var showingSaveSheet = false

    private var isSaved: Bool {
        savedEvents.contains { $0.eventID == event.id }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Label(event.kind.label, systemImage: event.kind.systemImage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(event.title)
                    .font(.largeTitle.bold())

                StatCard(title: "Date",
                         value: event.date.formatted(date: .abbreviated, time: .omitted))

                TimelineView(.periodic(from: .now, by: 60)) { timeline in
                    let countdown = EventsViewModel.countdown(for: event, at: timeline.date)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Countdown to event date")
                            .font(.headline)
                        HStack(spacing: 12) {
                            StatCard(title: "Days", value: "\(countdown.days)")
                            StatCard(title: "Hours", value: "\(countdown.hours)")
                            StatCard(title: "Minutes", value: "\(countdown.minutes)")
                        }
                        if countdown.hasArrived {
                            Text("The event date has arrived.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                section(title: "Where to see it", text: event.visibility)
                section(title: "What happens", text: event.summary)

                // TODO (Prompt 9): related news articles for this event.
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                showingSaveSheet = true
            } label: {
                Label(isSaved ? "Saved" : "Save",
                      systemImage: isSaved ? "bookmark.fill" : "bookmark")
            }
            .disabled(isSaved)
        }
        .sheet(isPresented: $showingSaveSheet) {
            SaveEventSheet(event: event)
        }
    }

    private func section(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(text)
        }
    }
}
