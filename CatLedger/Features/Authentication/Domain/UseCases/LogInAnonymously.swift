//
//  LogInAnonymously.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Logs in anonymously to start a demo session without a permanent registration.
final class LogInAnonymously {

    private let repository: AuthenticationProviding

    /// - Parameter repository: The authentication provider used to log in anonymously.
    init(repository: AuthenticationProviding) {
        self.repository = repository
    }

    /// - Returns: An anonymous session.
    func execute() async throws -> AuthenticationSession {
        try await repository.logInAnonymously()
    }
}
