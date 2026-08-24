//
//  TransactionProviding.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Defines the contract for transaction persistence.
/// The Domain layer depends only on this protocol — it has no knowledge of SwiftData or Firebase.
/// Conforming types live in the Data layer.
protocol TransactionProviding {

    /// Fetches all transactions belonging to a given profile.
    /// - Parameter profileId: The identifier of the profile.
    /// - Returns: An array of transactions, ordered by date descending.
    func fetchAll(for profileId: UUID) async throws -> [Transaction]

    /// Fetches all transactions with a split allocated to a given account.
    /// - Parameters:
    ///   - profileId: The identifier of the profile.
    ///   - accountId: The identifier of the account.
    /// - Returns: An array of transactions, ordered by date descending.
    func fetchAllByAccount(for profileId: UUID, accountId: UUID) async throws -> [Transaction]

    /// Fetches all transactions belonging to a given category.
    /// - Parameters:
    ///   - profileId: The identifier of the profile.
    ///   - category: The category to filter by.
    /// - Returns: An array of transactions, ordered by date descending.
    func fetchAllByCategory(for profileId: UUID, category: TransactionCategory) async throws -> [Transaction]

    /// Fetches all transactions within a date range.
    /// - Parameters:
    ///   - profileId: The identifier of the profile.
    ///   - from: The start of the date range, inclusive.
    ///   - until: The end of the date range, inclusive.
    /// - Returns: An array of transactions, ordered by date descending.
    func fetchAllByDateRange(for profileId: UUID, from: Date, until: Date) async throws -> [Transaction]

    /// Fetches a single transaction by its identifier.
    /// - Parameter id: The unique identifier of the transaction.
    /// - Returns: The matching transaction.
    func fetch(by id: UUID) async throws -> Transaction

    /// Persists a new transaction along with its splits.
    /// - Parameter transaction: The transaction to save.
    func save(_ transaction: Transaction) async throws

    /// Updates an existing transaction and its splits.
    /// - Parameter transaction: The transaction with updated values.
    func update(_ transaction: Transaction) async throws

    /// Deletes a transaction and all its associated splits.
    /// - Parameter id: The unique identifier of the transaction to delete.
    func delete(by id: UUID) async throws
}
