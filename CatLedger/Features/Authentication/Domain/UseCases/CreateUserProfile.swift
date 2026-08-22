//
//  CreateUserProfile.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Creates a new permanent user profile with email, password, and display name.
final class CreateUserProfile {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to create the account.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///   - firstName: The user's first name.
    ///   - lastName: The user's last name.
    /// - Returns: A session for the newly created user.
    func execute(email: String, password: String, firstName: String, lastName: String) async throws -> AuthSession {
        try await repository.createUserProfile(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName
        )
    }
}
