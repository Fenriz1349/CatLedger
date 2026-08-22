//
//  AddInstitutionTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct AddInstitutionTests {

    private let repository = InstitutionDouble()
    private let useCase: AddInstitution
    private let userId = UUID()

    init() {
        useCase = AddInstitution(repository: repository)
    }

    /// Returns a valid AddInstitutionInput with sensible defaults.
    private func makeInput(
        name: String = "BNP Paribas",
        category: InstitutionCategory = .bank,
        logoURL: String? = nil
    ) -> AddInstitutionInput {
        AddInstitutionInput(userId: userId, name: name, category: category, logoURL: logoURL)
    }

    @Test("Saves a valid institution to the repository")
    func execute_validInput_savesInstitution() async throws {
        try await useCase.execute(makeInput())
        let institutions = try await repository.fetchAll(for: userId)
        #expect(institutions.count == 1)
        #expect(institutions.first?.name == "BNP Paribas")
    }

    @Test("Trims whitespace from the name before saving")
    func execute_nameWithWhitespace_isTrimmed() async throws {
        try await useCase.execute(makeInput(name: "  BNP  "))
        let institutions = try await repository.fetchAll(for: userId)
        #expect(institutions.first?.name == "BNP")
    }

    @Test("Throws nameTooShort for an empty name")
    func execute_emptyName_throwsNameTooShort() async throws {
        await #expect(throws: InstitutionError.nameTooShort) {
            try await useCase.execute(makeInput(name: ""))
        }
    }

    @Test("Throws nameTooShort for a single character name")
    func execute_singleCharName_throwsNameTooShort() async throws {
        await #expect(throws: InstitutionError.nameTooShort) {
            try await useCase.execute(makeInput(name: "A"))
        }
    }

    @Test("Throws nameTooShort for a whitespace-only name")
    func execute_whitespaceOnlyName_throwsNameTooShort() async throws {
        await #expect(throws: InstitutionError.nameTooShort) {
            try await useCase.execute(makeInput(name: "   "))
        }
    }

    @Test("Throws nameTooLong for a name exceeding 50 characters")
    func execute_nameTooLong_throwsNameTooLong() async throws {
        await #expect(throws: InstitutionError.nameTooLong) {
            try await useCase.execute(makeInput(name: String(repeating: "A", count: 51)))
        }
    }

    @Test("Succeeds for a name of exactly 50 characters")
    func execute_nameExactly50Chars_succeeds() async throws {
        let name = String(repeating: "A", count: 50)
        try await useCase.execute(makeInput(name: name))
        let institutions = try await repository.fetchAll(for: userId)
        #expect(institutions.first?.name == name)
    }

    @Test("Throws duplicateName when the name is already used")
    func execute_duplicateName_throwsDuplicateName() async throws {
        try await repository.save(TestData.institution(userId: userId, name: "BNP Paribas"))
        await #expect(throws: InstitutionError.duplicateName) {
            try await useCase.execute(makeInput(name: "BNP Paribas"))
        }
    }

    @Test("Duplicate name check is case-insensitive")
    func execute_duplicateNameCaseInsensitive_throwsDuplicateName() async throws {
        try await repository.save(TestData.institution(userId: userId, name: "BNP Paribas"))
        await #expect(throws: InstitutionError.duplicateName) {
            try await useCase.execute(makeInput(name: "bnp paribas"))
        }
    }

    @Test("Allows the same name to be used by different users")
    func execute_sameNameDifferentUser_succeeds() async throws {
        try await repository.save(TestData.institution(userId: userId, name: "BNP Paribas"))
        let otherUserId = UUID()
        let otherInput = AddInstitutionInput(userId: otherUserId, name: "BNP Paribas", category: .bank, logoURL: nil)
        try await useCase.execute(otherInput)
        let otherInstitutions = try await repository.fetchAll(for: otherUserId)
        #expect(otherInstitutions.count == 1)
    }
}
