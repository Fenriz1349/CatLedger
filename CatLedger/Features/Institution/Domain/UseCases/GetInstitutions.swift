//
//  GetInstitutions.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Retrieves all institutions belonging to a given user.
final class GetInstitutions {

    private let repository: InstitutionProviding

    /// - Parameter repository: The data contract for institution persistence.
    init(repository: InstitutionProviding) {
        self.repository = repository
    }

    /// Fetches all institutions for a specific user, ordered by name.
    /// - Parameter userId: The identifier of the user.
    /// - Returns: An array of institutions belonging to the user.
    /// - Throws: `InstitutionError` if the fetch fails.
    func execute(for userId: UUID) async throws -> [Institution] {
        try await repository.fetchAll(for: userId)
    }
}
