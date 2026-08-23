//
//  ProfileDouble.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
@testable import CatLedger

/// In-memory test double implementation of ProfileProviding.
/// Used exclusively in unit tests to isolate UseCases from persistence layers.
final class ProfileDouble: ProfileProviding {

    private var current: Profile?

    /// Set this to force any method to throw a specific error.
    var errorToThrow: Error?

    /// Returns the current profile if one exists.
    func fetchCurrent() async throws -> Profile {
        if let error = errorToThrow { throw error }
        guard let profile = current else { throw ProfileError.notFound }
        return profile
    }

    /// Stores the profile as the current profile.
    func save(_ profile: Profile) async throws {
        if let error = errorToThrow { throw error }
        current = profile
    }

    /// Replaces the current profile with the updated one.
    func update(_ profile: Profile) async throws {
        if let error = errorToThrow { throw error }
        current = profile
    }

    /// Clears the current profile.
    func delete(by id: UUID) async throws {
        if let error = errorToThrow { throw error }
        current = nil
    }
}
