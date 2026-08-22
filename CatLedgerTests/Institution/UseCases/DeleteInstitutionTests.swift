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
    private let institutionId = UUID()

    init() {
        useCase = DeleteInstitution(repository: repository)
    }

    private func seedInstitution() async throws {
        try await repository.save(TestData.institution(id: institutionId))
    }

    @Test("Removes the institution record")
    func execute_existingId_institutionDeleted() async throws {
        try await seedInstitution()
        try await useCase.execute(id: institutionId)
        await #expect(throws: InstitutionError.notFound) {
            try await repository.fetch(by: institutionId)
        }
    }

    @Test("Throws notFound for an unknown institution")
    func execute_unknownId_throwsNotFound() async throws {
        await #expect(throws: InstitutionError.notFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
