//
//  ProfileProvider.swift
//  CatLedger
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation
import FirebaseFirestore

/// Concrete implementation of `ProfileProviding` backed by Firestore, via `FirebaseProfileSource`.
final class ProfileProvider: ProfileProviding {

    private let source: FirebaseProfileSource

    /// - Parameter source: The Firestore wrapper used to perform the underlying calls.
    init(source: FirebaseProfileSource = FirebaseProfileSource()) {
        self.source = source
    }

    /// Fetches the profile belonging to the given registration.
    /// - Returns: The matching profile.
    /// - Throws: `ProfileError.notFound` if no matching document exists or it can't be decoded.
    func fetch(by registrationId: UUID) async throws -> Profile {
        guard
            let data = try await source.fetch(byRegistrationId: registrationId.uuidString),
            let profile = decode(data)
        else { throw ProfileError.notFound }
        return profile
    }

    /// Persists a new profile.
    func save(_ profile: Profile) async throws {
        try await source.save(id: profile.id.uuidString, data: encode(profile))
    }

    /// Updates an existing profile.
    func update(_ profile: Profile) async throws {
        try await source.update(id: profile.id.uuidString, data: encode(profile, forMerge: true))
    }

    /// Deletes a profile permanently.
    func delete(by id: UUID) async throws {
        try await source.delete(id: id.uuidString)
    }

    // MARK: Private

    /// Decodes a raw Firestore document dictionary into a domain `Profile`.
    /// - Returns: nil if any required field is missing or malformed.
    private func decode(_ data: [String: Any]) -> Profile? {
        guard
            let idString = data["id"] as? String,
            let id = UUID(uuidString: idString),
            let registrationIdString = data["registrationId"] as? String,
            let registrationId = UUID(uuidString: registrationIdString),
            let displayName = data["displayName"] as? String
        else { return nil }
        return Profile(
            id: id,
            registrationId: registrationId,
            displayName: displayName,
            photoURL: data["photoURL"] as? String
        )
    }

    /// Encodes a domain `Profile` into a Firestore-compatible dictionary.
    /// When `forMerge` is true, a nil `photoURL` is written as `FieldValue.delete()` so a merge
    /// write actually clears the field instead of leaving the stale server value untouched.
    private func encode(_ profile: Profile, forMerge: Bool = false) -> [String: Any] {
        var data: [String: Any] = [
            "id": profile.id.uuidString,
            "registrationId": profile.registrationId.uuidString,
            "displayName": profile.displayName
        ]
        if let photoURL = profile.photoURL {
            data["photoURL"] = photoURL
        } else if forMerge {
            data["photoURL"] = FieldValue.delete()
        }
        return data
    }
}
