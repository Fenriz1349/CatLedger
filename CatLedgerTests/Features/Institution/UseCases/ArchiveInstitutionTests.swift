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

    init() {
        useCase = ArchiveInstitution(repository: repository)
    }

    @Test("Marks the institution as archived")
    func execute_archivesInstitution() async throws {
        let institution = TestData.institution()
        try await repository.save(institution)
        try await useCase.execute(id: institution.id)
        let updated = try await repository.fetch(by: institution.id)
        #expect(updated.isArchived)
    }

    @Test("Throws notFound for an unknown institution")
    func execute_unknownId_throwsNotFound() async throws {
        await #expect(throws: InstitutionError.notFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
