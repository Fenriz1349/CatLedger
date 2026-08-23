//
//  CreateProfile.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Creates a new permanent profile with email, password, and display name.
final class CreateProfile {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to create the account.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    /// - Parameters:
    ///   - email: The profile's email address.
    ///   - password: The profile's password.
    ///   - firstName: The profile's first name.
    ///   - lastName: The profile's last name.
    /// - Returns: A session for the newly created profile.
    func execute(email: String, password: String, firstName: String, lastName: String) async throws -> AuthSession {
        try await repository.createProfile(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName
        )
    }
}
