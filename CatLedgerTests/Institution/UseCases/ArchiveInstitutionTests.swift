//
//  ArchiveInstitutionTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct ArchiveInstitutionTests {

    private let repository = InstitutionDouble()
    private let useCase: ArchiveInstitution
    private let institutionId = UUID()

    init() {
        useCase = ArchiveInstitution(repository: repository)
    }

    private func seedInstitution() async throws {
        try await repository.save(TestData.institution(id: institutionId))
    }

    @Test("Marks the institution as archived")
    func execute_archivesInstitution() async throws {
        try await seedInstitution()
        try await useCase.execute(id: institutionId)
        let institution = try await repository.fetch(by: institutionId)
        #expect(institution.isArchived)
    }

    @Test("Throws notFound for an unknown institution")
    func execute_unknownId_throwsNotFound() async throws {
        await #expect(throws: InstitutionError.notFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
