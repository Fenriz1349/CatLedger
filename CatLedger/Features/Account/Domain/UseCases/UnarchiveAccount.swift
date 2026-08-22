//
//  UnarchiveAccount.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Restores a single account record to active status.
/// Cascading concerns (e.g. its parent institution) are a separate concern, orchestrated elsewhere.
final class UnarchiveAccount {

    private let repository: AccountProviding

    /// - Parameter repository: The data contract for account persistence.
    init(repository: AccountProviding) {
        self.repository = repository
    }

    /// - Parameter id: The unique identifier of the account to unarchive.
    /// - Throws: `AccountError.notFound` if no account matches the identifier.
    func execute(id: UUID) async throws {
        try await repository.unarchive(by: id)
    }
}
