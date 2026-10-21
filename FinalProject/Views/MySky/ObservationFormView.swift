//
//  ObservationFormView.swift
//  FinalProject
//

import SwiftUI
import SwiftData
import PhotosUI

/// Sheet for creating a new observation or editing an existing one.
struct ObservationFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CelestialBody.order) private var bodies: [CelestialBody]
    @Query(sort: \SavedEvent.date) private var savedEvents: [SavedEvent]

    @State private var viewModel = MySkyViewModel()

    private let existing: SkyObservation?
    private let draftPlanetName: String?
    @State private var title: String
    @State private var date: Date
    @State private var notes: String
    @State private var rating: Int
    @State private var selectedBody: CelestialBody?
    @State private var selectedEvent: SavedEvent?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var isLoadingPhoto = false
    @State private var isLocating = false

    init(observation: SkyObservation? = nil,
         prefilledBody: CelestialBody? = nil,
         prefilledEvent: SavedEvent? = nil,
         draft: ObservationDraft? = nil) {
        existing = observation
        draftPlanetName = draft?.planetName
        _title = State(initialValue: observation?.title ?? draft?.title ?? "")
        _date = State(initialValue: observation?.date ?? draft?.date ?? .now)
        _notes = State(initialValue: observation?.notes ?? draft?.notes ?? "")
        _rating = State(initialValue: observation?.rating ?? draft?.rating ?? 3)
        _selectedBody = State(initialValue: observation?.celestialBody ?? prefilledBody)
        _selectedEvent = State(initialValue: observation?.event ?? prefilledEvent)
        _photoData = State(initialValue: observation?.photoData)
        _latitude = State(initialValue: observation?.latitude)
        _longitude = State(initialValue: observation?.longitude)
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

                Section("Photo") {
                    if let photoData {
                        ObservationPhotoThumbnail(data: photoData, size: 120)
                        Button("Remove photo", role: .destructive) {
                            self.photoData = nil
                            selectedPhoto = nil
                            isLoadingPhoto = false
                            viewModel.photoMessage = nil
                        }
                    }
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label(photoData == nil ? "Choose photo" : "Change photo",
                              systemImage: "photo.on.rectangle")
                    }
                    if isLoadingPhoto {
                        ProgressView("Loading photo…")
                    }
                    if let message = viewModel.photoMessage {
                        Text(message).foregroundStyle(.red)
                    }
                }

                Section("Location") {
                    if let latitude, let longitude {
                        Text("Latitude: \(latitude.formatted(.number.precision(.fractionLength(4))))")
                        Text("Longitude: \(longitude.formatted(.number.precision(.fractionLength(4))))")
                    }
                    Button {
                        useCurrentLocation()
                    } label: {
                        Label("Use my location", systemImage: "location")
                    }
                    .disabled(isLocating)
                    if isLocating {
                        ProgressView("Finding location…")
                    }
                    if let message = viewModel.locationMessage {
                        Text(message).foregroundStyle(.red)
                    }
                }

                if let message = viewModel.errorMessage {
                    Text(message).foregroundStyle(.red)
                }
            }
            .navigationTitle(existing == nil ? "New Observation" : "Edit Observation")
            .navigationBarTitleDisplayMode(.inline)
            .task(id: bodies.count) {
                if existing == nil, selectedBody == nil, let draftPlanetName {
                    selectedBody = viewModel.planet(named: draftPlanetName, in: bodies)
                }
            }
            .onChange(of: selectedPhoto) { _, item in
                loadPhoto(item)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty ||
                                  isLoadingPhoto || isLocating)
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
                                  latitude: latitude,
                                  longitude: longitude,
                                  photoData: photoData,
                                  celestialBody: selectedBody,
                                  event: selectedEvent,
                                  context: context)
        if viewModel.errorMessage == nil {
            dismiss()
        }
    }

    private func loadPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }
        isLoadingPhoto = true
        Task {
            let data = await viewModel.loadObservationPhoto(item)
            guard selectedPhoto == item else { return }
            if let data { photoData = data }
            isLoadingPhoto = false
        }
    }

    private func useCurrentLocation() {
        isLocating = true
        Task {
            if let coordinates = await viewModel.currentObservationCoordinates() {
                latitude = coordinates.latitude
                longitude = coordinates.longitude
            }
            isLocating = false
        }
    }
}
