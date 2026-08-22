//
//  SignInAnonymously.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Signs in anonymously to start a demo session without a permanent account.
final class SignInAnonymously {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to sign in anonymously.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    /// - Returns: An anonymous session.
    func execute() async throws -> AuthSession {
        try await repository.signInAnonymously()
    }
}
