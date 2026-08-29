//
//  SignUp.swift
//  CatLedger
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation

/// Creates a new permanent registration with email and password.
final class SignUp {

    private let repository: AuthenticationProviding

    /// - Parameter repository: The authentication provider used to create the registration.
    init(repository: AuthenticationProviding) {
        self.repository = repository
    }

    /// - Parameters:
    ///   - email: The registration's email address.
    ///   - password: The registration's password.
    /// - Returns: A session for the newly created registration.
    func execute(email: String, password: String) async throws -> AuthenticationSession {
        try await repository.signUp(email: email, password: password)
    }
}
