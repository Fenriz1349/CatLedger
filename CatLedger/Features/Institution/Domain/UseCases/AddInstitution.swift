//
//  AddInstitution.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Handles the creation of a new institution for a given user.
/// Enforces all business rules before persisting.
final class AddInstitution {

    private let repository: InstitutionProviding

    /// - Parameter repository: The data contract for institution persistence.
    init(repository: InstitutionProviding) {
        self.repository = repository
    }

    /// Creates and persists a new institution.
    /// - Parameter input: The data required to create the institution.
    /// - Throws: `InstitutionError` if any business rule is violated.
    func execute(_ input: AddInstitutionInput) async throws {
        let trimmedName = input.name.trimmingCharacters(in: .whitespaces)
        guard trimmedName.count >= 2 else {
            throw InstitutionError.nameTooShort
        }
        guard trimmedName.count <= 50 else {
            throw InstitutionError.nameTooLong
        }

        let existingInstitutions = try await repository.fetchAll(for: input.userId)
        guard !existingInstitutions.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) else {
            throw InstitutionError.duplicateName
        }

        let institution = Institution(
            userId: input.userId,
            name: trimmedName,
            category: input.category,
            logoURL: input.logoURL
        )
        try await repository.save(institution)
    }
}
