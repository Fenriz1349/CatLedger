//
//  UpdateInstitution.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Handles updating an existing institution.
/// Re-enforces all business rules before persisting.
final class UpdateInstitution {

    private let repository: InstitutionProviding

    /// - Parameter repository: The data contract for institution persistence.
    init(repository: InstitutionProviding) {
        self.repository = repository
    }

    /// Updates an existing institution with new values.
    /// - Parameter input: The data required to update the institution.
    /// - Throws: `InstitutionError` if any business rule is violated.
    func execute(_ input: UpdateInstitutionInput) async throws {
        let trimmedName = input.name.trimmingCharacters(in: .whitespaces)
        guard trimmedName.count >= 2 else {
            throw InstitutionError.nameTooShort
        }
        guard trimmedName.count <= 50 else {
            throw InstitutionError.nameTooLong
        }

        let existingInstitutions = try await repository.fetchAll(for: input.profileId)
        let hasDuplicateName = existingInstitutions.contains {
            $0.name.lowercased() == trimmedName.lowercased() && $0.id != input.id
        }
        guard !hasDuplicateName else {
            throw InstitutionError.duplicateName
        }

        let currentInstitution = try await repository.fetch(by: input.id)
        let updatedInstitution = Institution(
            id: input.id,
            profileId: input.profileId,
            name: trimmedName,
            category: input.category,
            logoURL: input.logoURL,
            isArchived: currentInstitution.isArchived
        )
        try await repository.update(updatedInstitution)
    }
}
