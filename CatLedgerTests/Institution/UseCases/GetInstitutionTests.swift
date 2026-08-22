//
//  GetInstitutionTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct GetInstitutionTests {

    private let repository = InstitutionDouble()
    private let useCase: GetInstitution

    init() {
        useCase = GetInstitution(repository: repository)
    }

    /// Seeds and returns an institution with a known id.
    private func seedInstitution() async throws -> UUID {
        let institution = Institution(userId: UUID(), name: "BNP Paribas", category: .bank)
        try await repository.save(institution)
        return institution.id
    }

    @Test("Returns the institution matching an existing id")
    func execute_existingId_returnsInstitution() async throws {
        let id = try await seedInstitution()
        let result = try await useCase.execute(id: id)
        #expect(result.id == id)
    }

    @Test("Returns the institution with its expected name")
    func execute_existingId_returnsCorrectName() async throws {
        let id = try await seedInstitution()
        let result = try await useCase.execute(id: id)
        #expect(result.name == "BNP Paribas")
    }

    @Test("Throws notFound when no institution matches the id")
    func execute_unknownId_throwsNotFound() async throws {
        await #expect(throws: InstitutionError.notFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
