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

    private var store: [Profile] = []

    /// Set this to force any method to throw a specific error.
    var errorToThrow: Error?

    /// Returns the profile in the store matching the given registration.
    func fetch(by registrationId: UUID) async throws -> Profile {
        if let error = errorToThrow { throw error }
        guard let profile = store.first(where: { $0.registrationId == registrationId }) else {
            throw ProfileError.notFound
        }
        return profile
    }

    /// Appends the profile to the in-memory store.
    func save(_ profile: Profile) async throws {
        if let error = errorToThrow { throw error }
        store.append(profile)
    }

    /// Replaces the existing profile in the store with the updated one.
    func update(_ profile: Profile) async throws {
        if let error = errorToThrow { throw error }
        guard let index = store.firstIndex(where: { $0.id == profile.id }) else {
            throw ProfileError.notFound
        }
        store[index] = profile
    }

    /// Removes the profile matching the given id from the store.
    func delete(by id: UUID) async throws {
        if let error = errorToThrow { throw error }
        guard store.contains(where: { $0.id == id }) else {
            throw ProfileError.notFound
        }
        store.removeAll { $0.id == id }
    }
}
