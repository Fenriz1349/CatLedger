//
//  UpdateInstitutionTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct UpdateInstitutionTests {

    private let repository = InstitutionDouble()
    private let useCase: UpdateInstitution
    private let profileId = UUID()

    init() {
        useCase = UpdateInstitution(repository: repository)
    }

    /// Returns a valid UpdateInstitutionInput with sensible defaults, scoped to the shared profileId.
    private func makeInput(
        id: UUID,
        name: String = "Caisse d'Épargne",
        category: InstitutionCategory = .bank
    ) -> UpdateInstitutionInput {
        TestData.updateInstitutionInput(id: id, profileId: profileId, name: name, category: category)
    }

    @Test("Persists the new values for a valid update")
    func execute_validInput_updatesInstitution() async throws {
        let institution = TestData.institution(profileId: profileId)
        try await repository.save(institution)
        let input = makeInput(id: institution.id)
        try await useCase.execute(input)
        let updated = try await repository.fetch(by: institution.id)
        #expect(updated.name == input.name)
    }

    @Test("Succeeds when updating with its own unchanged name")
    func execute_sameNameSameId_succeeds() async throws {
        let institution = TestData.institution(profileId: profileId, name: "BNP Paribas")
        try await repository.save(institution)
        try await useCase.execute(makeInput(id: institution.id, name: "BNP Paribas", category: .insurance))
        let updated = try await repository.fetch(by: institution.id)
        #expect(updated.category == .insurance)
    }

    @Test("Throws nameTooShort for a name shorter than 2 characters")
    func execute_nameTooShort_throwsNameTooShort() async throws {
        let institution = TestData.institution(profileId: profileId)
        try await repository.save(institution)
        await #expect(throws: InstitutionError.nameTooShort) {
            try await useCase.execute(makeInput(id: institution.id, name: "A"))
        }
    }

    @Test("Throws nameTooLong for a name exceeding 50 characters")
    func execute_nameTooLong_throwsNameTooLong() async throws {
        let institution = TestData.institution(profileId: profileId)
        try await repository.save(institution)
        await #expect(throws: InstitutionError.nameTooLong) {
            try await useCase.execute(makeInput(id: institution.id, name: String(repeating: "A", count: 51)))
        }
    }

    @Test("Throws duplicateName when the name is used by another institution")
    func execute_duplicateName_throwsDuplicateName() async throws {
        try await repository.save(TestData.institution(profileId: profileId, name: "Caisse d'Épargne"))
        let institution = TestData.institution(profileId: profileId, name: "BNP Paribas")
        try await repository.save(institution)
        await #expect(throws: InstitutionError.duplicateName) {
            try await useCase.execute(makeInput(id: institution.id, name: "Caisse d'Épargne"))
        }
    }
}
