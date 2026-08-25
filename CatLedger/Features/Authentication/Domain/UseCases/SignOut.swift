//
//  SignOut.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Signs out the current registration and clears the local session.
final class SignOut {

    private let repository: AuthenticationProviding

    /// - Parameter repository: The authentication provider used to sign out.
    init(repository: AuthenticationProviding) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.signOut()
    }
}
