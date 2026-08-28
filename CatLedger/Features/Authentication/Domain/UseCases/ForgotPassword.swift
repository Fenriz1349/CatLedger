//
//  ForgottenPassword.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Sends a password reset email to the given address.
final class ForgottenPassword {

    private let repository: AuthenticationProviding

    /// - Parameter repository: The authentication provider used to send the reset email.
    init(repository: AuthenticationProviding) {
        self.repository = repository
    }

    /// - Parameter email: The email address of the registration to reset.
    func execute(email: String) async throws {
        try await repository.forgottenPassword(email: email)
    }
}
