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

    @Test("Returns the institution matching an existing id")
    func execute_existingId_returnsInstitution() async throws {
        let institution = TestData.institution()
        try await repository.save(institution)
        let result = try await useCase.execute(id: institution.id)
        #expect(result.id == institution.id)
    }

    @Test("Returns the institution with its expected name")
    func execute_existingId_returnsCorrectName() async throws {
        let institution = TestData.institution()
        try await repository.save(institution)
        let result = try await useCase.execute(id: institution.id)
        #expect(result.name == institution.name)
    }

    @Test("Throws notFound when no institution matches the id")
    func execute_unknownId_throwsNotFound() async throws {
        await #expect(throws: InstitutionError.notFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
