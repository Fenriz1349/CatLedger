//
//  ExpireAnonymousSession.swift
//  CatLedger
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation

/// Checks whether the current anonymous session has exceeded its validity period.
/// If so, deletes the underlying registration and clears the local session state.
final class ExpireAnonymousSession {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to check and expire the session.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    /// Expires the anonymous session if it has exceeded its validity period.
    /// - Returns: `true` if the session was expired and deleted, `false` if still valid.
    func execute() async -> Bool {
        guard repository.isAnonymousSessionExpired() else { return false }
        await repository.expireAnonymousSession()
        return true
    }
}
