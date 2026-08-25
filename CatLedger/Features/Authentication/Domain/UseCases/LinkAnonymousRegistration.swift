//
//  LinkAnonymousRegistration.swift
//  CatLedger
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation

/// Links the current anonymous session to a permanent email/password registration.
final class LinkAnonymousRegistration {

    private let repository: AuthenticationProviding

    /// - Parameter repository: The authentication provider used to link the registration.
    init(repository: AuthenticationProviding) {
        self.repository = repository
    }

    /// - Parameters:
    ///   - email: The email address for the new permanent registration.
    ///   - password: The password for the new permanent registration.
    /// - Returns: An updated, non-anonymous session.
    func execute(email: String, password: String) async throws -> AuthSession {
        try await repository.linkAnonymousRegistration(toEmail: email, password: password)
    }
}
