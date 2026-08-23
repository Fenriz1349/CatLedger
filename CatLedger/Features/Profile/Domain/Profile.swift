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
/// authenticated account owns, so the two happen to coincide. But keeping them as separate
/// concepts from the start means the rest of the app (Institution, Account, Transaction — every
/// one of them scoped by `profileId`, never by an auth identifier) doesn't have to change shape
/// if a single authenticated account ever needs to manage more than one space: a personal
/// budget, a side business, an association's finances. `Authentication` stays limited to proving
/// who is signed in; a `Profile` is which ledger they're currently looking at. Multi-profile
/// support itself (switching, sharing, membership/roles) is not built and not planned yet — this
/// is only about not baking a one-to-one assumption into every other feature's data model.
///
/// `displayName` uses `|` as a separator between first and last name (e.g. `"Jean-Pierre|Du Saint"`),
/// allowing compound names on both sides without ambiguity.
struct Profile: Identifiable, Equatable, Codable, Sendable {

    let id: UUID
    let displayName: String
    let email: String
    let photoURL: String?

    /// The first name extracted from `displayName` using the `|` separator.
    var firstName: String { displayName.components(separatedBy: "|").first ?? displayName }

    /// The last name extracted from `displayName` using the `|` separator.
    var lastName: String { displayName.components(separatedBy: "|").last ?? "" }

    /// Creates a new Profile.
    /// - Parameters:
    ///   - id: Internal unique identifier. Defaults to a new UUID.
    ///   - displayName: Pipe-separated full name in the form `"firstName|lastName"`.
    ///   - email: Email address of the profile.
    ///   - photoURL: Optional URL string pointing to the profile's photo.
    init(
        id: UUID = UUID(),
        displayName: String,
        email: String,
        photoURL: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.photoURL = photoURL
    }
}
