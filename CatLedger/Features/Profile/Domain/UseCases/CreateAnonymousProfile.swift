//
//  CreateAnonymousProfile.swift
//  CatLedger
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation

/// Creates a placeholder profile for an anonymous demo session, with no name or email to validate.
final class CreateAnonymousProfile {

    private let repository: ProfileProviding

    /// - Parameter repository: The data contract for profile persistence.
    init(repository: ProfileProviding) {
        self.repository = repository
    }

    /// Creates and persists a new placeholder profile.
    /// - Parameter registrationId: The registration this profile belongs to.
    /// - Returns: The newly created profile.
    func execute(registrationId: UUID) async throws -> Profile {
        let profile = Profile(registrationId: registrationId, displayName: "", email: "")
        try await repository.save(profile)
        return profile
    }
}
