//
//  LogInWithEmail.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Logs in with an existing email and password.
final class LogInWithEmail {

    private let repository: AuthenticationProviding

    /// - Parameter repository: The authentication provider used to log in.
    init(repository: AuthenticationProviding) {
        self.repository = repository
    }

    /// - Parameters:
    ///   - email: The email address to log in with.
    ///   - password: The password to log in with.
    /// - Returns: A session for the authenticated registration.
    func execute(email: String, password: String) async throws -> AuthenticationSession {
        try await repository.login(withEmail: email, password: password)
    }
}
