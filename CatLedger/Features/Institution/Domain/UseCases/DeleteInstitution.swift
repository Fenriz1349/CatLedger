//
//  DeleteInstitution.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Permanently deletes a single institution record.
/// Cleaning up its accounts (and their transactions) is a separate concern, orchestrated elsewhere.
final class DeleteInstitution {

    private let repository: InstitutionProviding

    /// - Parameter repository: The data contract for institution persistence.
    init(repository: InstitutionProviding) {
        self.repository = repository
    }

    /// - Parameter id: The unique identifier of the institution to delete.
    /// - Throws: `InstitutionError.notFound` if no institution matches the identifier.
    func execute(id: UUID) async throws {
        try await repository.delete(by: id)
    }
}
