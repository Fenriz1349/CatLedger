//
//  IsAnonymousSessionExpired.swift
//  CatLedger
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation

/// Checks whether the current anonymous session has exceeded its validity period.
final class IsAnonymousSessionExpired {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to check the session.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    /// - Returns: `true` if the session is anonymous and has exceeded its validity period.
    func execute() -> Bool {
        repository.isAnonymousSessionExpired()
    }
}
