//
//  GetInstitution.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Retrieves a single institution by its unique identifier.
final class GetInstitution {

    private let repository: InstitutionProviding

    /// - Parameter repository: The data contract for institution persistence.
    init(repository: InstitutionProviding) {
        self.repository = repository
    }

    /// Fetches a single institution by its identifier.
    /// - Parameter id: The unique identifier of the institution.
    /// - Returns: The matching institution.
    /// - Throws: `InstitutionError.notFound` if no institution matches the identifier.
    func execute(id: UUID) async throws -> Institution {
        try await repository.fetch(by: id)
    }
}
