//
//  AuthenticationSession.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Represents an active authentication session.
struct AuthenticationSession: Equatable, Sendable {
    /// The unique identifier of the authenticated registration.
    let registrationId: UUID
    /// The registration's email address, or nil for an anonymous session.
    let email: String?

    /// Firebase never assigns an email to an anonymous account, so its absence is authoritative.
    var isAnonymous: Bool { email == nil }
}
