//
//  LocationService.swift
//  FinalProject
//

import CoreLocation
import Foundation

struct ObservationCoordinates {
    let latitude: Double
    let longitude: Double
}

/// Requests one location fix for an observation; it does not track in the background.
@MainActor
final class LocationService: NSObject, @preconcurrency CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<ObservationCoordinates, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func currentCoordinates() async throws -> ObservationCoordinates {
        guard continuation == nil else { throw LocationError.requestInProgress }

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            case .denied, .restricted:
                finish(.failure(LocationError.permissionDenied))
            @unknown default:
                finish(.failure(LocationError.unavailable))
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard continuation != nil else { return }
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            finish(.failure(LocationError.permissionDenied))
        case .notDetermined:
            break
        @unknown default:
            finish(.failure(LocationError.unavailable))
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            finish(.failure(LocationError.unavailable))
            return
        }
        finish(.success(ObservationCoordinates(latitude: location.coordinate.latitude,
                                               longitude: location.coordinate.longitude)))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finish(.failure(LocationError.unavailable))
    }

    private func finish(_ result: Result<ObservationCoordinates, Error>) {
        continuation?.resume(with: result)
        continuation = nil
    }
}

enum LocationError: LocalizedError {
    case permissionDenied
    case requestInProgress
    case unavailable

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location access is off. Allow it in Settings to use your location."
        case .requestInProgress:
            return "A location request is already in progress."
        case .unavailable:
            return "Couldn't get your location. Check Location Services and try again."
        }
    }
}
