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

    /// Fetches all transactions belonging to a given user.
    /// - Parameter userId: The identifier of the user.
    /// - Returns: An array of transactions, ordered by date descending.
    func fetchAll(for userId: UUID) async throws -> [Transaction]

    /// Fetches all transactions with a split allocated to a given account.
    /// - Parameters:
    ///   - userId: The identifier of the user.
    ///   - accountId: The identifier of the account.
    /// - Returns: An array of transactions, ordered by date descending.
    func fetchAllByAccount(for userId: UUID, accountId: UUID) async throws -> [Transaction]

    /// Fetches all transactions belonging to a given category.
    /// - Parameters:
    ///   - userId: The identifier of the user.
    ///   - category: The category to filter by.
    /// - Returns: An array of transactions, ordered by date descending.
    func fetchAllByCategory(for userId: UUID, category: TransactionCategory) async throws -> [Transaction]

    /// Fetches all transactions within a date range.
    /// - Parameters:
    ///   - userId: The identifier of the user.
    ///   - from: The start of the date range, inclusive.
    ///   - to: The end of the date range, inclusive.
    /// - Returns: An array of transactions, ordered by date descending.
    func fetchAllByDateRange(for userId: UUID, from: Date, to: Date) async throws -> [Transaction]

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
