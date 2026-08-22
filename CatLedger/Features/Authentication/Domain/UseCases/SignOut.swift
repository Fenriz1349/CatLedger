//
//  SignOut.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Signs out the current user and clears the local session.
final class SignOut {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to sign out.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.signOut()
    }
}
