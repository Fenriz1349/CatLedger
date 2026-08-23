//
//  LinkAnonymousAccount.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Links the current anonymous session to a permanent email/password account,
/// preserving all existing profile data.
final class LinkAnonymousAccount {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to link the account.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    /// - Parameters:
    ///   - email: The email address for the new permanent account.
    ///   - password: The password for the new permanent account.
    ///   - firstName: The profile's first name.
    ///   - lastName: The profile's last name.
    /// - Returns: An updated, non-anonymous session.
    func execute(email: String, password: String, firstName: String, lastName: String) async throws -> AuthSession {
        try await repository.linkAnonymousAccount(
            toEmail: email,
            password: password,
            firstName: firstName,
            lastName: lastName
        )
    }
}
