//
//  GetCurrentProfile.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Retrieves the current profile.
final class GetCurrentProfile {

    private let repository: ProfileProviding

    /// - Parameter repository: The data contract for profile persistence.
    init(repository: ProfileProviding) {
        self.repository = repository
    }

    /// Fetches the profile belonging to the given registration.
    /// - Parameter registrationId: The registration whose profile to fetch.
    /// - Returns: The matching profile.
    /// - Throws: `ProfileError.notFound` if no profile exists for that registration.
    func execute(registrationId: UUID) async throws -> Profile {
        try await repository.fetch(by: registrationId)
    }
}
