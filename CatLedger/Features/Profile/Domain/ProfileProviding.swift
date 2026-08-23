//
//  ProfileProviding.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Defines the contract for profile persistence.
/// The Domain layer depends only on this protocol — it has no knowledge of SwiftData or Firebase.
/// Conforming types live in the Data layer.
protocol ProfileProviding {

    /// Fetches the current profile.
    /// - Returns: The current profile.
    func fetchCurrent() async throws -> Profile

    /// Persists a new profile.
    /// - Parameter profile: The profile to save.
    func save(_ profile: Profile) async throws

    /// Updates an existing profile.
    /// - Parameter profile: The profile with updated values.
    func update(_ profile: Profile) async throws

    /// Deletes a profile and all associated data permanently.
    /// - Parameter id: The internal unique identifier of the profile to delete.
    func delete(by id: UUID) async throws
}
