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
    private let userId = UUID()

    init() {
        useCase = UpdateInstitution(repository: repository)
    }

    /// Returns a valid UpdateInstitutionInput with sensible defaults.
    private func makeInput(
        id: UUID,
        name: String = "Caisse d'Épargne",
        category: InstitutionCategory = .bank
    ) -> UpdateInstitutionInput {
        UpdateInstitutionInput(id: id, userId: userId, name: name, category: category, logoURL: nil)
    }

    @Test("Persists the new values for a valid update")
    func execute_validInput_updatesInstitution() async throws {
        let institution = TestData.institution(userId: userId)
        try await repository.save(institution)
        try await useCase.execute(makeInput(id: institution.id, name: "Caisse d'Épargne"))
        let updated = try await repository.fetch(by: institution.id)
        #expect(updated.name == "Caisse d'Épargne")
    }

    @Test("Succeeds when updating with its own unchanged name")
    func execute_sameNameSameId_succeeds() async throws {
        let institution = TestData.institution(userId: userId, name: "BNP Paribas")
        try await repository.save(institution)
        try await useCase.execute(makeInput(id: institution.id, name: "BNP Paribas", category: .insurance))
        let updated = try await repository.fetch(by: institution.id)
        #expect(updated.category == .insurance)
    }

    @Test("Throws nameTooShort for a name shorter than 2 characters")
    func execute_nameTooShort_throwsNameTooShort() async throws {
        let institution = TestData.institution(userId: userId)
        try await repository.save(institution)
        await #expect(throws: InstitutionError.nameTooShort) {
            try await useCase.execute(makeInput(id: institution.id, name: "A"))
        }
    }

    @Test("Throws nameTooLong for a name exceeding 50 characters")
    func execute_nameTooLong_throwsNameTooLong() async throws {
        let institution = TestData.institution(userId: userId)
        try await repository.save(institution)
        await #expect(throws: InstitutionError.nameTooLong) {
            try await useCase.execute(makeInput(id: institution.id, name: String(repeating: "A", count: 51)))
        }
    }

    @Test("Throws duplicateName when the name is used by another institution")
    func execute_duplicateName_throwsDuplicateName() async throws {
        try await repository.save(TestData.institution(userId: userId, name: "Caisse d'Épargne"))
        let institution = TestData.institution(userId: userId, name: "BNP Paribas")
        try await repository.save(institution)
        await #expect(throws: InstitutionError.duplicateName) {
            try await useCase.execute(makeInput(id: institution.id, name: "Caisse d'Épargne"))
        }
    }
}
