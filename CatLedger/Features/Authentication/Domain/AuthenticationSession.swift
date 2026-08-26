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
    /// Indicates whether the session is anonymous (not yet linked to a permanent registration).
    let isAnonymous: Bool
}
