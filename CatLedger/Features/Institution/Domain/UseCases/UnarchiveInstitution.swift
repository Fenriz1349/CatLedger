//
//  UnarchiveInstitution.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Restores a single institution record to active status.
/// Cascading the restore to its accounts is a separate concern, orchestrated elsewhere.
final class UnarchiveInstitution {

    private let repository: InstitutionProviding

    /// - Parameter repository: The data contract for institution persistence.
    init(repository: InstitutionProviding) {
        self.repository = repository
    }

    /// - Parameter id: The unique identifier of the institution to unarchive.
    /// - Throws: `InstitutionError.notFound` if no institution matches the identifier.
    func execute(id: UUID) async throws {
        try await repository.unarchive(by: id)
    }
}
