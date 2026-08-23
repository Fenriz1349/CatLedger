//
//  SignUp.swift
//  CatLedger
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation

/// Creates a new permanent registration with email and password.
final class SignUp {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to create the registration.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    /// - Parameters:
    ///   - email: The registration's email address.
    ///   - password: The registration's password.
    /// - Returns: A session for the newly created registration.
    func execute(email: String, password: String) async throws -> AuthSession {
        try await repository.signUp(email: email, password: password)
    }
}
