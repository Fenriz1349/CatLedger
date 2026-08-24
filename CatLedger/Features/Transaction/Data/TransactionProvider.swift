//
//  TransactionProvider.swift
//  CatLedger
//
//  Created by Julien Cotte on 24/08/2026.
//

import Foundation
import FirebaseFirestore

/// Concrete implementation of `TransactionProviding` backed by Firestore, via `FirebaseTransactionSource`.
final class TransactionProvider: TransactionProviding {

    private let source: FirebaseTransactionSource

    /// - Parameter source: The Firestore wrapper used to perform the underlying calls.
    init(source: FirebaseTransactionSource = FirebaseTransactionSource()) {
        self.source = source
    }

    /// Fetches all transactions belonging to a given profile, ordered by date descending.
    func fetchAll(for profileId: UUID) async throws -> [Transaction] {
        try await source.fetchAll(profileId: profileId.uuidString).compactMap(decode)
    }

    /// Fetches all transactions with a split allocated to a given account.
    /// Filters client-side after a full profile fetch rather than a dedicated Firestore query —
    /// kept naive for now, to revisit if profile transaction volumes make it worth optimizing.
    func fetchAllByAccount(for profileId: UUID, accountId: UUID) async throws -> [Transaction] {
        try await fetchAll(for: profileId).filter { $0.belongs(to: accountId) }
    }

    /// Fetches all transactions belonging to a given category.
    /// See `fetchAllByAccount` for why this filters client-side rather than querying Firestore.
    func fetchAllByCategory(for profileId: UUID, category: TransactionCategory) async throws -> [Transaction] {
        try await fetchAll(for: profileId).filter { $0.category == category }
    }

    /// Fetches all transactions within a date range.
    /// See `fetchAllByAccount` for why this filters client-side rather than querying Firestore.
    func fetchAllByDateRange(for profileId: UUID, from: Date, to: Date) async throws -> [Transaction] {
        try await fetchAll(for: profileId).filter { $0.date >= from && $0.date <= to }
    }

    /// Fetches a single transaction by its identifier.
    /// - Throws: `TransactionError.notFound` if no matching document exists or it can't be decoded.
    func fetch(by id: UUID) async throws -> Transaction {
        guard
            let data = try await source.fetch(id: id.uuidString),
            let transaction = decode(data)
        else { throw TransactionError.notFound }
        return transaction
    }

    /// Persists a new transaction along with its splits.
    func save(_ transaction: Transaction) async throws {
        try await source.save(id: transaction.id.uuidString, data: encode(transaction))
    }

    /// Updates an existing transaction and its splits.
    func update(_ transaction: Transaction) async throws {
        try await source.update(id: transaction.id.uuidString, data: encode(transaction, forMerge: true))
    }

    /// Deletes a transaction and all its associated splits.
    func delete(by id: UUID) async throws {
        try await source.delete(id: id.uuidString)
    }

    // MARK: Private

    /// Decodes a raw Firestore document dictionary into a domain `Transaction`.
    /// - Returns: nil if any required field is missing or malformed, or if no split decodes.
    private func decode(_ data: [String: Any]) -> Transaction? {
        guard
            let idString = data["id"] as? String,
            let id = UUID(uuidString: idString),
            let profileIdString = data["profileId"] as? String,
            let profileId = UUID(uuidString: profileIdString),
            let label = data["label"] as? String,
            let date = data["date"] as? Timestamp,
            let totalAmount = data["totalAmount"] as? Double,
            let isExpense = data["isExpense"] as? Bool,
            let categoryRaw = data["category"] as? String,
            let category = TransactionCategory(rawValue: categoryRaw),
            let rawSplits = data["splits"] as? [[String: Any]],
            let isChecked = data["isChecked"] as? Bool,
            let updatedAt = data["updatedAt"] as? Timestamp
        else { return nil }

        let splits = rawSplits.compactMap(decodeSplit)
        guard !splits.isEmpty else { return nil }

        return Transaction(
            id: id,
            profileId: profileId,
            label: label,
            date: date.dateValue(),
            totalAmount: totalAmount,
            note: data["note"] as? String,
            isExpense: isExpense,
            category: category,
            splits: splits,
            isChecked: isChecked,
            updatedAt: updatedAt.dateValue()
        )
    }

    /// Decodes a raw split dictionary into a domain `TransactionSplit`.
    private func decodeSplit(_ data: [String: Any]) -> TransactionSplit? {
        guard
            let idString = data["id"] as? String,
            let id = UUID(uuidString: idString),
            let accountIdString = data["accountId"] as? String,
            let accountId = UUID(uuidString: accountIdString),
            let amount = data["amount"] as? Double
        else { return nil }
        return TransactionSplit(id: id, accountId: accountId, amount: amount)
    }

    /// Encodes a domain `Transaction` into a Firestore-compatible dictionary.
    /// When `forMerge` is true, a nil `note` is written as `FieldValue.delete()` so a merge
    /// write actually clears the field instead of leaving the stale server value untouched.
    private func encode(_ transaction: Transaction, forMerge: Bool = false) -> [String: Any] {
        var data: [String: Any] = [
            "id": transaction.id.uuidString,
            "profileId": transaction.profileId.uuidString,
            "label": transaction.label,
            "date": Timestamp(date: transaction.date),
            "totalAmount": transaction.totalAmount,
            "isExpense": transaction.isExpense,
            "category": transaction.category.rawValue,
            "splits": transaction.splits.map(encodeSplit),
            "isChecked": transaction.isChecked,
            "updatedAt": Timestamp(date: transaction.updatedAt)
        ]
        if let note = transaction.note {
            data["note"] = note
        } else if forMerge {
            data["note"] = FieldValue.delete()
        }
        return data
    }

    /// Encodes a domain `TransactionSplit` into a Firestore-compatible dictionary.
    private func encodeSplit(_ split: TransactionSplit) -> [String: Any] {
        [
            "id": split.id.uuidString,
            "accountId": split.accountId.uuidString,
            "amount": split.amount
        ]
    }
}
