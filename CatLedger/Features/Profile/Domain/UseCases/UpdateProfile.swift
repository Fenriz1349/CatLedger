//
//  UpdateProfile.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Handles updating the current profile.
/// Enforces all business rules before persisting.
final class UpdateProfile {

    private let repository: ProfileProviding

    /// - Parameter repository: The data contract for profile persistence.
    init(repository: ProfileProviding) {
        self.repository = repository
    }

    /// Updates the current profile with new values.
    /// - Parameter input: The data required to update the profile.
    /// - Throws: `ProfileError` if any business rule is violated.
    func execute(_ input: UpdateProfileInput) async throws {
        let firstName = input.firstName.trimmingCharacters(in: .whitespaces)
        let lastName = input.lastName.trimmingCharacters(in: .whitespaces)
        guard firstName.count <= 50 else { throw ProfileError.nameTooLong }
        guard lastName.count <= 50 else { throw ProfileError.nameTooLong }

        let updated = Profile(
            id: input.id,
            registrationId: input.registrationId,
            displayName: "\(firstName)|\(lastName)",
            photoURL: input.photoURL
        )
        try await repository.update(updated)
    }
}
