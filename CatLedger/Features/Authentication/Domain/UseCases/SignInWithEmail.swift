//
//  SignInWithEmail.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Signs in an existing profile using email and password.
final class SignInWithEmail {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to sign in.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    /// - Parameters:
    ///   - email: The profile's email address.
    ///   - password: The profile's password.
    /// - Returns: A session for the authenticated profile.
    func execute(email: String, password: String) async throws -> AuthSession {
        try await repository.signInWithEmail(email: email, password: password)
    }
}
