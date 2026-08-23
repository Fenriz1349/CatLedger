//
//  DeleteRegistration.swift
//  CatLedger
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation

/// Deletes the current registration and clears the local session.
final class DeleteRegistration {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to delete the registration.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.deleteRegistration()
    }
}
