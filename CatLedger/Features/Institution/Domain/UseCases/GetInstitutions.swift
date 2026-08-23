//
//  GetInstitutions.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Retrieves all institutions belonging to a given profile.
final class GetInstitutions {

    private let repository: InstitutionProviding

    /// - Parameter repository: The data contract for institution persistence.
    init(repository: InstitutionProviding) {
        self.repository = repository
    }

    /// Fetches all institutions for a specific profile, ordered by name.
    /// - Parameter profileId: The identifier of the profile.
    /// - Returns: An array of institutions belonging to the profile.
    /// - Throws: `InstitutionError` if the fetch fails.
    func execute(for profileId: UUID) async throws -> [Institution] {
        try await repository.fetchAll(for: profileId)
    }
}
