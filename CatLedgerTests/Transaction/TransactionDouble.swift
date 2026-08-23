//
//  TransactionDouble.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
@testable import CatLedger

/// In-memory test double implementation of TransactionProviding.
/// Used exclusively in unit tests to isolate UseCases from persistence layers.
final class TransactionDouble: TransactionProviding {

    private var store: [Transaction] = []

    /// Set this to force any method to throw a specific error.
    var errorToThrow: Error?

    /// Returns all transactions in the store belonging to the given profile.
    func fetchAll(for profileId: UUID) async throws -> [Transaction] {
        if let error = errorToThrow { throw error }
        return store.filter { $0.profileId == profileId }
    }

    /// Returns all transactions in the store holding a split on the given account.
    func fetchAllByAccount(for profileId: UUID, accountId: UUID) async throws -> [Transaction] {
        if let error = errorToThrow { throw error }
        return store.filter { $0.profileId == profileId && $0.belongs(to: accountId) }
    }

    /// Returns all transactions in the store matching the given category.
    func fetchAllByCategory(for profileId: UUID, category: TransactionCategory) async throws -> [Transaction] {
        if let error = errorToThrow { throw error }
        return store.filter { $0.profileId == profileId && $0.category == category }
    }

    /// Returns all transactions in the store within the given date range.
    func fetchAllByDateRange(for profileId: UUID, from: Date, to: Date) async throws -> [Transaction] {
        if let error = errorToThrow { throw error }
        return store.filter { $0.profileId == profileId && $0.date >= from && $0.date <= to }
    }

    /// Returns the transaction in the store matching the given id.
    func fetch(by id: UUID) async throws -> Transaction {
        if let error = errorToThrow { throw error }
        guard let transaction = store.first(where: { $0.id == id }) else {
            throw TransactionError.notFound
        }
        return transaction
    }

    /// Appends the transaction to the in-memory store.
    func save(_ transaction: Transaction) async throws {
        if let error = errorToThrow { throw error }
        store.append(transaction)
    }

    /// Replaces the existing transaction in the store with the updated one.
    func update(_ transaction: Transaction) async throws {
        if let error = errorToThrow { throw error }
        guard let index = store.firstIndex(where: { $0.id == transaction.id }) else {
            throw TransactionError.notFound
        }
        store[index] = transaction
    }

    /// Removes the transaction matching the given id from the store.
    func delete(by id: UUID) async throws {
        if let error = errorToThrow { throw error }
        guard store.contains(where: { $0.id == id }) else {
            throw TransactionError.notFound
        }
        store.removeAll { $0.id == id }
    }
}
