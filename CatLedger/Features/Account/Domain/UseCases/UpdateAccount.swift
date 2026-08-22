//
//  UpdateAccount.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Handles updating an existing account.
/// Re-enforces all business rules before persisting.
final class UpdateAccount {

    private let repository: AccountProviding

    /// - Parameter repository: The data contract for account persistence.
    init(repository: AccountProviding) {
        self.repository = repository
    }

    /// Updates an existing account with new values.
    /// - Parameter input: The data required to update the account.
    /// - Throws: `AccountError` if any business rule is violated.
    func execute(_ input: UpdateAccountInput) async throws {
        let trimmedName = input.name.trimmingCharacters(in: .whitespaces)
        guard trimmedName.count >= 2 else {
            throw AccountError.nameTooShort
        }
        guard trimmedName.count <= 50 else {
            throw AccountError.nameTooLong
        }

        let existingAccounts = try await repository.fetchAll(for: input.institutionId)
        let hasDuplicateName = existingAccounts.contains {
            $0.name.lowercased() == trimmedName.lowercased() && $0.id != input.id
        }
        guard !hasDuplicateName else {
            throw AccountError.duplicateName
        }

        let currentAccount = try await repository.fetch(by: input.id)
        let updatedAccount = Account(
            id: input.id,
            institutionId: input.institutionId,
            name: trimmedName,
            category: input.category,
            isArchived: currentAccount.isArchived
        )
        try await repository.update(updatedAccount)
    }
}
