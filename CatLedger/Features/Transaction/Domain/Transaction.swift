//
//  Transaction.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Represents a real-world financial event (e.g. a restaurant meal).
/// Belongs directly to a Profile. Account relationships are managed via splits.
/// The total amount is always positive — isExpense determines the direction.
/// A transaction must always have at least one associated TransactionSplit.
struct Transaction: Identifiable, Equatable, Codable, Sendable, Hashable {

    let id: UUID
    let profileId: UUID
    let label: String
    let date: Date
    let totalAmount: Double
    let note: String?
    let isExpense: Bool
    let category: TransactionCategory
    let splits: [TransactionSplit]
    /// Whether the profile has manually reconciled this transaction against a bank statement.
    let isChecked: Bool
    /// Date of the last local or remote modification, used for sync conflict resolution.
    let updatedAt: Date

    /// Creates a new Transaction.
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - profileId: The identifier of the profile this transaction belongs to.
    ///   - label: Human-readable description of the transaction.
    ///   - date: The date the transaction occurred.
    ///   - totalAmount: The total amount of the transaction. Always positive.
    ///   - note: Optional free-form note.
    ///   - isExpense: Whether the transaction is an expense (true) or an income (false).
    ///   - category: Category of the transaction.
    ///   - splits: The account allocations for this transaction.
    ///   - isChecked: Whether the transaction has been reconciled. Defaults to false.
    ///   - updatedAt: Last modification date. Defaults to the current date.
    init(
        id: UUID = UUID(),
        profileId: UUID,
        label: String,
        date: Date,
        totalAmount: Double,
        note: String? = nil,
        isExpense: Bool,
        category: TransactionCategory,
        splits: [TransactionSplit],
        isChecked: Bool = false,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.profileId = profileId
        self.label = label
        self.date = date
        self.totalAmount = totalAmount
        self.note = note
        self.isExpense = isExpense
        self.category = category
        self.splits = splits
        self.isChecked = isChecked
        self.updatedAt = updatedAt
    }
}

extension Transaction {

    /// True when any of the transaction's splits is allocated to the given account.
    func belongs(to accountId: UUID) -> Bool {
        splits.contains { $0.accountId == accountId }
    }
}
