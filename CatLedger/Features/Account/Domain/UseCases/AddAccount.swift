//
//  AddAccount.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Handles the creation of a new account for a given institution.
/// Enforces all business rules before persisting.
final class AddAccount {

    private let repository: AccountProviding

    /// - Parameter repository: The data contract for account persistence.
    init(repository: AccountProviding) {
        self.repository = repository
    }

    /// Creates and persists a new account.
    /// - Parameters:
    ///   - institutionId: The identifier of the institution this account belongs to.
    ///   - name: Name of the account. Must be between 2 and 50 characters.
    ///   - category: Category of the account.
    /// - Returns: The newly created account.
    /// - Throws: `AccountError` if any business rule is violated.
    @discardableResult
    func execute(
        institutionId: UUID,
        name: String,
        category: AccountCategory
    ) async throws -> Account {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard trimmedName.count >= 2 else {
            throw AccountError.nameTooShort
        }
        guard trimmedName.count <= 50 else {
            throw AccountError.nameTooLong
        }

        let existingAccounts = try await repository.fetchAllActive(for: institutionId)
        guard !existingAccounts.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) else {
            throw AccountError.duplicateName
        }

        let account = Account(institutionId: institutionId, name: trimmedName, category: category)
        try await repository.save(account)
        return account
    }
}
