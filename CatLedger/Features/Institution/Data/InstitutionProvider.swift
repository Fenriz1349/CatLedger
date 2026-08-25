//
//  InstitutionProvider.swift
//  CatLedger
//
//  Created by Julien Cotte on 24/08/2026.
//

import Foundation
import FirebaseFirestore

/// Concrete implementation of `InstitutionProviding` backed by Firestore, via `FirebaseInstitutionSource`.
final class InstitutionProvider: InstitutionProviding {

    private let source: FirebaseInstitutionSource

    /// - Parameter source: The Firestore wrapper used to perform the underlying calls.
    init(source: FirebaseInstitutionSource = FirebaseInstitutionSource()) {
        self.source = source
    }

    /// Fetches a single institution by its identifier.
    /// - Throws: `InstitutionError.notFound` if no matching document exists or it can't be decoded.
    func fetch(by id: UUID) async throws -> Institution {
        guard
            let data = try await source.fetch(id: id.uuidString),
            let institution = decode(data)
        else { throw InstitutionError.notFound }
        return institution
    }

    /// Fetches all institutions belonging to a given profile, ordered by name.
    func fetchAll(for profileId: UUID) async throws -> [Institution] {
        try await source.fetchAll(profileId: profileId.uuidString).compactMap(decode)
    }

    /// Persists a new institution.
    func save(_ institution: Institution) async throws {
        try await source.save(id: institution.id.uuidString, data: encode(institution))
    }

    /// Updates an existing institution.
    func update(_ institution: Institution) async throws {
        try await source.update(id: institution.id.uuidString, data: encode(institution, forMerge: true))
    }

    /// Archives an institution by marking it as inactive.
    func archive(by id: UUID) async throws {
        try await setArchived(true, for: id)
    }

    /// Restores an archived institution to active status.
    func unarchive(by id: UUID) async throws {
        try await setArchived(false, for: id)
    }

    /// Deletes an institution.
    func delete(by id: UUID) async throws {
        try await source.delete(id: id.uuidString)
    }

    // MARK: Private

    /// Updates only the `isArchived` and `updatedAt` fields, without a full read-modify-write.
    private func setArchived(_ value: Bool, for id: UUID) async throws {
        try await source.update(id: id.uuidString, data: ["isArchived": value, "updatedAt": Timestamp(date: Date())])
    }

    /// Decodes a raw Firestore document dictionary into a domain `Institution`.
    /// - Returns: nil if any required field is missing or malformed.
    private func decode(_ data: [String: Any]) -> Institution? {
        guard
            let idString = data["id"] as? String,
            let id = UUID(uuidString: idString),
            let profileIdString = data["profileId"] as? String,
            let profileId = UUID(uuidString: profileIdString),
            let name = data["name"] as? String,
            let categoryRaw = data["category"] as? String,
            let category = InstitutionCategory(rawValue: categoryRaw),
            let isArchived = data["isArchived"] as? Bool,
            let updatedAt = data["updatedAt"] as? Timestamp
        else { return nil }
        return Institution(
            id: id,
            profileId: profileId,
            name: name,
            category: category,
            logoURL: data["logoURL"] as? String,
            isArchived: isArchived,
            updatedAt: updatedAt.dateValue()
        )
    }

    /// Encodes a domain `Institution` into a Firestore-compatible dictionary.
    /// When `forMerge` is true, a nil `logoURL` is written as `FieldValue.delete()` so a merge
    /// write actually clears the field instead of leaving the stale server value untouched.
    private func encode(_ institution: Institution, forMerge: Bool = false) -> [String: Any] {
        var data: [String: Any] = [
            "id": institution.id.uuidString,
            "profileId": institution.profileId.uuidString,
            "name": institution.name,
            "category": institution.category.rawValue,
            "isArchived": institution.isArchived,
            "updatedAt": Timestamp(date: institution.updatedAt)
        ]
        if let logoURL = institution.logoURL {
            data["logoURL"] = logoURL
        } else if forMerge {
            data["logoURL"] = FieldValue.delete()
        }
        return data
    }
}
