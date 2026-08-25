//
//  ResolveSession.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Attempts to restore an existing authentication session from local storage.
final class ResolveSession {

    private let repository: AuthenticationProviding

    /// - Parameter repository: The authentication provider used to resolve the session.
    init(repository: AuthenticationProviding) {
        self.repository = repository
    }

    /// - Returns: The existing session, or nil if none is stored.
    func execute() async -> AuthenticationSession? {
        await repository.resolveSession()
    }
}
