//
//  SignInAnonymously.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Signs in anonymously to start a demo session without a permanent registration.
final class SignInAnonymously {

    private let repository: AuthenticationProviding

    /// - Parameter repository: The authentication provider used to sign in anonymously.
    init(repository: AuthenticationProviding) {
        self.repository = repository
    }

    /// - Returns: An anonymous session.
    func execute() async throws -> AuthSession {
        try await repository.signInAnonymously()
    }
}
