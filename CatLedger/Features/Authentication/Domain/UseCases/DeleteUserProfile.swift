//
//  DeleteUserProfile.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Deletes the authentication account and clears the local session.
final class DeleteUserProfile {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to delete the account.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.deleteUserProfile()
    }
}
