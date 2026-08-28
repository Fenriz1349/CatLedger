//
//  SignUpAnonymously.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Creates a new anonymous registration to start a demo session.
final class SignUpAnonymously {

    private let repository: AuthenticationProviding

    /// - Parameter repository: The authentication provider used to create the anonymous registration.
    init(repository: AuthenticationProviding) {
        self.repository = repository
    }

    /// - Returns: An anonymous session.
    func execute() async throws -> AuthenticationSession {
        try await repository.signUpAnonymously()
    }
}
