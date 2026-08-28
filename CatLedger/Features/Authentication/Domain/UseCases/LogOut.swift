//
//  SignOut.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Logs out the current registration and clears the local session.
final class LogOut {

    private let repository: AuthenticationProviding

    /// - Parameter repository: The authentication provider used to log out.
    init(repository: AuthenticationProviding) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.logOut()
    }
}
