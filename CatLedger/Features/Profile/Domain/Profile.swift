//
//  Profile.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Represents a financial space: the owner of a set of institutions, accounts, and transactions.
/// Only knows its internal UUID — remote identifiers are handled exclusively in the Data layer.
///
/// Named `Profile` rather than `User` on purpose. A `Profile` is not "the person signed in" —
/// it's "the ledger being managed". Today, signing in resolves to exactly one `Profile` that the
/// signed-in registration owns, so the two happen to coincide. But keeping them as separate
/// concepts from the start means the rest of the app (Institution, Account, Transaction — every
/// one of them scoped by `profileId`, never by an auth identifier) doesn't have to change shape
/// if a single registration ever needs to manage more than one space: a personal
/// budget, a side business, an association's finances. `Authentication` stays limited to proving
/// who is signed in; a `Profile` is which ledger they're currently looking at. Multi-profile
/// support itself (switching, sharing, membership/roles) is not built and not planned yet — this
/// is only about not baking a one-to-one assumption into every other feature's data model.
///
/// `displayName` uses `|` as a separator between first and last name (e.g. `"Jean-Pierre|Du Saint"`),
/// allowing compound names on both sides without ambiguity.
struct Profile: Identifiable, Equatable, Codable, Sendable {

    let id: UUID
    let registrationId: UUID
    let displayName: String
    let photoURL: String?
    /// Date of the last local or remote modification, used for sync conflict resolution.
    let updatedAt: Date

    /// The first name extracted from `displayName` using the `|` separator.
    var firstName: String { displayName.components(separatedBy: "|").first ?? displayName }

    /// The last name extracted from `displayName` using the `|` separator.
    var lastName: String { displayName.components(separatedBy: "|").last ?? "" }

    /// Creates a new Profile.
    /// - Parameters:
    ///   - id: Internal unique identifier. Defaults to a new UUID.
    ///   - registrationId: The registration this profile belongs to.
    ///   - displayName: Pipe-separated full name in the form `"firstName|lastName"`.
    ///   - photoURL: Optional URL string pointing to the profile's photo.
    ///   - updatedAt: Last modification date. Defaults to the current date.
    init(
        id: UUID = UUID(),
        registrationId: UUID,
        displayName: String,
        photoURL: String? = nil,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.registrationId = registrationId
        self.displayName = displayName
        self.photoURL = photoURL
        self.updatedAt = updatedAt
    }
}
