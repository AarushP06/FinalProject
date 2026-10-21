//
//  LaunchesViewModel.swift
//  FinalProject
//

import Foundation
import Observation

/// Loading state for the upcoming launches section.
@MainActor
@Observable
final class LaunchesViewModel {
    var launches: [Launch] = []
    var isLoading = false
    var errorMessage: String?

    private let service = LaunchService()

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await service.upcomingLaunches()
            launches = result.launches
            errorMessage = result.warning
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
