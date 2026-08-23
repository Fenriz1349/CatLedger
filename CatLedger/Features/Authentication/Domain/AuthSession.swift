//
//  AuthSession.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Represents an active authentication session for a profile.
struct AuthSession: Equatable, Sendable {
    /// The unique identifier of the authenticated profile.
    let profileId: UUID
    /// Indicates whether the session is anonymous (no linked account).
    let isAnonymous: Bool
}
