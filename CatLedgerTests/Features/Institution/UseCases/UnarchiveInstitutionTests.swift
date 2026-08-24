//
//  UnarchiveInstitutionTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct UnarchiveInstitutionTests {

    private let repository = InstitutionDouble()
    private let useCase: UnarchiveInstitution

    init() {
        useCase = UnarchiveInstitution(repository: repository)
    }

    @Test("Restores the institution to active status")
    func execute_unarchivesInstitution() async throws {
        let institution = TestData.institution(isArchived: true)
        try await repository.save(institution)
        try await useCase.execute(id: institution.id)
        let updated = try await repository.fetch(by: institution.id)
        #expect(!updated.isArchived)
    }

    @Test("Throws notFound for an unknown institution")
    func execute_unknownId_throwsNotFound() async throws {
        await #expect(throws: InstitutionError.notFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
