//
//  AccountProvider.swift
//  CatLedger
//
//  Created by Julien Cotte on 24/08/2026.
//

import Foundation
import FirebaseFirestore

/// Concrete implementation of `AccountProviding` backed by Firestore, via `FirebaseAccountSource`.
final class AccountProvider: AccountProviding {

    private let source: FirebaseAccountSource

    /// - Parameter source: The Firestore wrapper used to perform the underlying calls.
    init(source: FirebaseAccountSource = FirebaseAccountSource()) {
        self.source = source
    }

    /// Fetches all accounts belonging to a given institution, ordered by name.
    func fetchAll(for institutionId: UUID) async throws -> [Account] {
        try await source.fetchAll(institutionId: institutionId.uuidString).compactMap(decode)
    }

    /// Fetches all active accounts belonging to a given institution, ordered by name.
    /// Filters client-side rather than adding a second Firestore equality clause, to avoid
    /// requiring a composite index alongside the existing `institutionId` + `name` order.
    func fetchAllActive(for institutionId: UUID) async throws -> [Account] {
        try await fetchAll(for: institutionId).filter { !$0.isArchived }
    }

    /// Fetches all archived accounts belonging to a given institution, ordered by name.
    func fetchAllArchived(for institutionId: UUID) async throws -> [Account] {
        try await fetchAll(for: institutionId).filter(\.isArchived)
    }

    /// Fetches a single account by its identifier.
    /// - Throws: `AccountError.notFound` if no matching document exists or it can't be decoded.
    func fetch(by id: UUID) async throws -> Account {
        guard
            let data = try await source.fetch(id: id.uuidString),
            let account = decode(data)
        else { throw AccountError.notFound }
        return account
    }

    /// Persists a new account.
    func save(_ account: Account) async throws {
        try await source.save(id: account.id.uuidString, data: encode(account))
    }

    /// Updates an existing account.
    func update(_ account: Account) async throws {
        try await source.update(id: account.id.uuidString, data: encode(account))
    }

    /// Archives an account by marking it as inactive.
    func archive(by id: UUID) async throws {
        try await setArchived(true, for: id)
    }

    /// Restores an archived account to active status.
    func unarchive(by id: UUID) async throws {
        try await setArchived(false, for: id)
    }

    /// Permanently deletes an account.
    func delete(by id: UUID) async throws {
        try await source.delete(id: id.uuidString)
    }

    // MARK: Private

    /// Updates only the `isArchived` and `updatedAt` fields, without a full read-modify-write.
    private func setArchived(_ value: Bool, for id: UUID) async throws {
        try await source.update(id: id.uuidString, data: ["isArchived": value, "updatedAt": Timestamp(date: Date())])
    }

    /// Decodes a raw Firestore document dictionary into a domain `Account`.
    /// - Returns: nil if any required field is missing or malformed.
    private func decode(_ data: [String: Any]) -> Account? {
        guard
            let idString = data["id"] as? String,
            let id = UUID(uuidString: idString),
            let institutionIdString = data["institutionId"] as? String,
            let institutionId = UUID(uuidString: institutionIdString),
            let name = data["name"] as? String,
            let categoryRaw = data["category"] as? String,
            let category = AccountCategory(rawValue: categoryRaw),
            let isArchived = data["isArchived"] as? Bool,
            let updatedAt = data["updatedAt"] as? Timestamp
        else { return nil }
        return Account(
            id: id,
            institutionId: institutionId,
            name: name,
            category: category,
            isArchived: isArchived,
            updatedAt: updatedAt.dateValue()
        )
    }

    /// Encodes a domain `Account` into a Firestore-compatible dictionary.
    private func encode(_ account: Account) -> [String: Any] {
        [
            "id": account.id.uuidString,
            "institutionId": account.institutionId.uuidString,
            "name": account.name,
            "category": account.category.rawValue,
            "isArchived": account.isArchived,
            "updatedAt": Timestamp(date: account.updatedAt)
        ]
    }
}
