//
//  GetCurrentProfile.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Retrieves the current authenticated profile.
final class GetCurrentProfile {

    private let repository: ProfileProviding

    /// - Parameter repository: The data contract for profile persistence.
    init(repository: ProfileProviding) {
        self.repository = repository
    }

    /// Fetches the current authenticated profile.
    /// - Returns: The current profile.
    /// - Throws: `ProfileError.notFound` if no profile is currently authenticated.
    func execute() async throws -> Profile {
        try await repository.fetchCurrent()
    }
}
