//
//  DeleteAccount.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Permanently deletes a single account record.
final class DeleteAccount {

    private let repository: AccountProviding

    /// - Parameter repository: The data contract for account persistence.
    init(repository: AccountProviding) {
        self.repository = repository
    }

    /// - Parameter id: The unique identifier of the account to delete.
    /// - Throws: `AccountError.notFound` if no account matches the identifier.
    func execute(id: UUID) async throws {
        try await repository.delete(by: id)
    }
}
