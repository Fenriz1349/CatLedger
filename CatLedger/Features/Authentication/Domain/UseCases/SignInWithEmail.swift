//
//  SignInWithEmail.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Signs in with an existing email and password.
final class SignInWithEmail {

    private let repository: AuthenticationProviding

    /// - Parameter repository: The authentication provider used to sign in.
    init(repository: AuthenticationProviding) {
        self.repository = repository
    }

    /// - Parameters:
    ///   - email: The email address to sign in with.
    ///   - password: The password to sign in with.
    /// - Returns: A session for the authenticated registration.
    func execute(email: String, password: String) async throws -> AuthSession {
        try await repository.signInWithEmail(email: email, password: password)
    }
}
