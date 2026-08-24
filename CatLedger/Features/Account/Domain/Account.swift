//
//  Account.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Represents a financial account belonging to an Institution.
/// Balance is not stored — it is computed on demand via GetAccountBalance.
struct Account: Identifiable, Equatable, Codable, Sendable, Hashable {

    let id: UUID
    let institutionId: UUID
    let name: String
    let category: AccountCategory
    let isArchived: Bool
    /// Date of the last local or remote modification, used for sync conflict resolution.
    let updatedAt: Date

    /// Creates a new Account.
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - institutionId: The identifier of the institution this account belongs to.
    ///   - name: Human-readable name of the account (e.g. "Livret A").
    ///   - category: Category of the account.
    ///   - isArchived: Whether the account is archived. Defaults to false.
    ///   - updatedAt: Last modification date. Defaults to the current date.
    nonisolated init(
        id: UUID = UUID(),
        institutionId: UUID,
        name: String,
        category: AccountCategory,
        isArchived: Bool = false,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.institutionId = institutionId
        self.name = name
        self.category = category
        self.isArchived = isArchived
        self.updatedAt = updatedAt
    }
}

extension Account {

    /// True when the account belongs to the given institution.
    func belongs(to institutionId: UUID) -> Bool {
        self.institutionId == institutionId
    }
}
