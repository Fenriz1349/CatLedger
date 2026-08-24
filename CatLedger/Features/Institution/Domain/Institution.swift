//
//  Institution.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Represents a financial institution belonging to a profile.
/// An institution owns one or more accounts.
struct Institution: Identifiable, Equatable, Codable, Sendable, Hashable {

    let id: UUID
    let profileId: UUID
    let name: String
    let category: InstitutionCategory
    let logoURL: String?
    /// Whether this institution has been archived by the profile.
    let isArchived: Bool
    /// Date of the last local or remote modification, used for sync conflict resolution.
    let updatedAt: Date

    /// Creates a new Institution.
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - profileId: The identifier of the profile this institution belongs to.
    ///   - name: Human-readable name of the institution (e.g. "Caisse d'Épargne").
    ///   - category: Category of the institution.
    ///   - logoURL: Optional URL string pointing to the institution's logo.
    ///   - isArchived: Whether the institution is archived. Defaults to false.
    ///   - updatedAt: Last modification date. Defaults to the current date.
    nonisolated init(
        id: UUID = UUID(),
        profileId: UUID,
        name: String,
        category: InstitutionCategory,
        logoURL: String? = nil,
        isArchived: Bool = false,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.profileId = profileId
        self.name = name
        self.category = category
        self.logoURL = logoURL
        self.isArchived = isArchived
        self.updatedAt = updatedAt
    }
}
