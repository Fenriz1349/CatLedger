//
//  CreateProfile.swift
//  CatLedger
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation

/// Handles the creation of a new profile.
/// Enforces all business rules before persisting.
final class CreateProfile {

    private let repository: ProfileProviding

    /// - Parameter repository: The data contract for profile persistence.
    init(repository: ProfileProviding) {
        self.repository = repository
    }

    /// Creates and persists a new profile.
    /// - Parameters:
    ///   - firstName: The profile's first name.
    ///   - lastName: The profile's last name.
    ///   - email: The profile's email address.
    ///   - photoURL: Optional URL string pointing to the profile's photo.
    /// - Returns: The newly created profile.
    /// - Throws: `ProfileError` if any business rule is violated.
    func execute(
        firstName: String,
        lastName: String,
        email: String,
        photoURL: String? = nil
    ) async throws -> Profile {
        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespaces)
        let trimmedLastName = lastName.trimmingCharacters(in: .whitespaces)
        guard trimmedFirstName.count <= 50 else { throw ProfileError.nameTooLong }
        guard trimmedLastName.count <= 50 else { throw ProfileError.nameTooLong }
        guard email.contains("@") else { throw ProfileError.invalidEmail }

        let profile = Profile(
            displayName: "\(trimmedFirstName)|\(trimmedLastName)",
            email: email,
            photoURL: photoURL
        )
        try await repository.save(profile)
        return profile
    }
}
