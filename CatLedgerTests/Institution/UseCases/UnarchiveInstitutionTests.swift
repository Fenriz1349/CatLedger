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
    private let institutionId = UUID()

    init() {
        useCase = UnarchiveInstitution(repository: repository)
    }

    private func seedArchivedInstitution() async throws {
        try await repository.save(TestData.institution(id: institutionId, isArchived: true))
    }

    @Test("Restores the institution to active status")
    func execute_unarchivesInstitution() async throws {
        try await seedArchivedInstitution()
        try await useCase.execute(id: institutionId)
        let institution = try await repository.fetch(by: institutionId)
        #expect(!institution.isArchived)
    }

    @Test("Throws notFound for an unknown institution")
    func execute_unknownId_throwsNotFound() async throws {
        await #expect(throws: InstitutionError.notFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
