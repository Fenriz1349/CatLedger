//
//  AddAccountTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct AddAccountTests {

    private let repository = AccountDouble()
    private let useCase: AddAccount
    private let institutionId = UUID()

    init() {
        useCase = AddAccount(repository: repository)
    }

    /// Seeds an account belonging to the shared institutionId.
    private func seedAccount(name: String = "Livret A") async throws {
        try await repository.save(TestData.account(institutionId: institutionId, name: name))
    }

    @Test("Saves a valid account to the repository")
    func execute_validInput_savesAccount() async throws {
        try await useCase.execute(institutionId: institutionId, name: "Livret A", category: .savings)
        let accounts = try await repository.fetchAll(for: institutionId)
        #expect(accounts.count == 1)
        #expect(accounts.first?.name == "Livret A")
    }

    @Test("Trims whitespace from the name before saving")
    func execute_nameWithWhitespace_isTrimmed() async throws {
        try await useCase.execute(institutionId: institutionId, name: "  Livret A  ", category: .savings)
        let accounts = try await repository.fetchAll(for: institutionId)
        #expect(accounts.first?.name == "Livret A")
    }

    @Test("Throws nameTooShort for an empty name")
    func execute_emptyName_throwsNameTooShort() async throws {
        await #expect(throws: AccountError.nameTooShort) {
            try await useCase.execute(institutionId: institutionId, name: "", category: .savings)
        }
    }

    @Test("Throws nameTooShort for a single character name")
    func execute_singleCharName_throwsNameTooShort() async throws {
        await #expect(throws: AccountError.nameTooShort) {
            try await useCase.execute(institutionId: institutionId, name: "A", category: .savings)
        }
    }

    @Test("Throws nameTooLong for a name exceeding 50 characters")
    func execute_nameTooLong_throwsNameTooLong() async throws {
        let longName = String(repeating: "A", count: 51)
        await #expect(throws: AccountError.nameTooLong) {
            try await useCase.execute(institutionId: institutionId, name: longName, category: .savings)
        }
    }

    @Test("Succeeds for a name of exactly 50 characters")
    func execute_nameExactly50Chars_succeeds() async throws {
        let maxName = String(repeating: "A", count: 50)
        try await useCase.execute(institutionId: institutionId, name: maxName, category: .savings)
        let accounts = try await repository.fetchAll(for: institutionId)
        #expect(accounts.first?.name == maxName)
    }

    @Test("Throws duplicateName when the name is already used")
    func execute_duplicateName_throwsDuplicateName() async throws {
        try await seedAccount(name: "Livret A")
        await #expect(throws: AccountError.duplicateName) {
            try await useCase.execute(institutionId: institutionId, name: "Livret A", category: .savings)
        }
    }

    @Test("Duplicate name check is case-insensitive")
    func execute_duplicateNameCaseInsensitive_throwsDuplicateName() async throws {
        try await seedAccount(name: "Livret A")
        await #expect(throws: AccountError.duplicateName) {
            try await useCase.execute(institutionId: institutionId, name: "livret a", category: .savings)
        }
    }

    @Test("Allows the same name to be used in different institutions")
    func execute_sameNameDifferentInstitution_succeeds() async throws {
        try await seedAccount(name: "Livret A")
        let otherInstitutionId = UUID()
        try await useCase.execute(institutionId: otherInstitutionId, name: "Livret A", category: .savings)
        let accounts = try await repository.fetchAll(for: otherInstitutionId)
        #expect(accounts.count == 1)
    }
}
