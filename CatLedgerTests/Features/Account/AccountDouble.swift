//
//  AccountDouble.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
@testable import CatLedger

/// In-memory test double implementation of AccountProviding.
/// Used exclusively in unit tests to isolate UseCases from persistence layers.
final class AccountDouble: AccountProviding {

    private var store: [Account] = []

    /// Set this to force any method to throw a specific error.
    var errorToThrow: Error?

    /// Returns all accounts in the store belonging to the given institution.
    func fetchAll(for institutionId: UUID) async throws -> [Account] {
        if let error = errorToThrow { throw error }
        return store.filter { $0.institutionId == institutionId }
    }

    /// Returns all active accounts in the store belonging to the given institution.
    func fetchAllActive(for institutionId: UUID) async throws -> [Account] {
        if let error = errorToThrow { throw error }
        return store.filter { $0.institutionId == institutionId && !$0.isArchived }
    }

    /// Returns all archived accounts in the store belonging to the given institution.
    func fetchAllArchived(for institutionId: UUID) async throws -> [Account] {
        if let error = errorToThrow { throw error }
        return store.filter { $0.institutionId == institutionId && $0.isArchived }
    }

    /// Returns the account in the store matching the given id.
    func fetch(by id: UUID) async throws -> Account {
        if let error = errorToThrow { throw error }
        guard let account = store.first(where: { $0.id == id }) else {
            throw AccountError.notFound
        }
        return account
    }

    /// Appends the account to the in-memory store.
    func save(_ account: Account) async throws {
        if let error = errorToThrow { throw error }
        store.append(account)
    }

    /// Replaces the existing account in the store with the updated one.
    func update(_ account: Account) async throws {
        if let error = errorToThrow { throw error }
        guard let index = store.firstIndex(where: { $0.id == account.id }) else {
            throw AccountError.notFound
        }
        store[index] = account
    }

    /// Marks the matching account as archived in the store.
    func archive(by id: UUID) async throws {
        if let error = errorToThrow { throw error }
        try setArchived(true, for: id)
    }

    /// Restores the matching account to active status in the store.
    func unarchive(by id: UUID) async throws {
        if let error = errorToThrow { throw error }
        try setArchived(false, for: id)
    }

    /// Rebuilds the stored account with a new `isArchived` value (the entity is immutable).
    private func setArchived(_ value: Bool, for id: UUID) throws {
        guard let index = store.firstIndex(where: { $0.id == id }) else {
            throw AccountError.notFound
        }
        let current = store[index]
        store[index] = Account(
            id: current.id,
            institutionId: current.institutionId,
            name: current.name,
            category: current.category,
            isArchived: value,
            updatedAt: current.updatedAt
        )
    }

    /// Removes the account matching the given id from the store.
    func delete(by id: UUID) async throws {
        if let error = errorToThrow { throw error }
        guard store.contains(where: { $0.id == id }) else {
            throw AccountError.notFound
        }
        store.removeAll { $0.id == id }
    }
}
