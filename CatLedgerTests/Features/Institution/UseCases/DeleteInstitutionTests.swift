//
//  DeleteInstitutionTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct DeleteInstitutionTests {

    private let repository = InstitutionDouble()
    private let useCase: DeleteInstitution

    init() {
        useCase = DeleteInstitution(repository: repository)
    }

    @Test("Removes the institution record")
    func execute_existingId_institutionDeleted() async throws {
        let institution = TestData.institution()
        try await repository.save(institution)
        try await useCase.execute(id: institution.id)
        await #expect(throws: InstitutionError.notFound) {
            try await repository.fetch(by: institution.id)
        }
    }

    @Test("Throws notFound for an unknown institution")
    func execute_unknownId_throwsNotFound() async throws {
        await #expect(throws: InstitutionError.notFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
