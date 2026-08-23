//
//  UpdateAccountTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct UpdateAccountTests {

    private let repository = AccountDouble()
    private let useCase: UpdateAccount
    private let institutionId = UUID()

    init() {
        useCase = UpdateAccount(repository: repository)
    }

    /// Seeds and returns an account with a known id.
    private func seedAccount(name: String = "Livret A") async throws -> UUID {
        let account = TestData.account(institutionId: institutionId, name: name)
        try await repository.save(account)
        return account.id
    }

    /// Returns a valid UpdateAccountInput with sensible defaults, scoped to the shared institutionId.
    private func makeInput(
        id: UUID,
        name: String = "PEL",
        category: AccountCategory = .savings
    ) -> UpdateAccountInput {
        TestData.updateAccountInput(id: id, institutionId: institutionId, name: name, category: category)
    }

    @Test("Persists the new values for a valid update")
    func execute_validInput_updatesAccount() async throws {
        let id = try await seedAccount()
        try await useCase.execute(makeInput(id: id, name: "PEL"))
        let updated = try await repository.fetch(by: id)
        #expect(updated.name == "PEL")
    }

    @Test("Succeeds when updating with its own unchanged name")
    func execute_sameNameSameId_succeeds() async throws {
        let id = try await seedAccount(name: "Livret A")
        try await useCase.execute(makeInput(id: id, name: "Livret A", category: .creditCard))
        let updated = try await repository.fetch(by: id)
        #expect(updated.category == .creditCard)
    }

    @Test("Throws nameTooShort for a name shorter than 2 characters")
    func execute_nameTooShort_throwsNameTooShort() async throws {
        let id = try await seedAccount()
        await #expect(throws: AccountError.nameTooShort) {
            try await useCase.execute(makeInput(id: id, name: "A"))
        }
    }

    @Test("Throws nameTooLong for a name exceeding 50 characters")
    func execute_nameTooLong_throwsNameTooLong() async throws {
        let id = try await seedAccount()
        await #expect(throws: AccountError.nameTooLong) {
            try await useCase.execute(makeInput(id: id, name: String(repeating: "A", count: 51)))
        }
    }

    @Test("Throws duplicateName when the name is used by another account")
    func execute_duplicateName_throwsDuplicateName() async throws {
        _ = try await seedAccount(name: "PEL")
        let id = try await seedAccount(name: "Livret A")
        await #expect(throws: AccountError.duplicateName) {
            try await useCase.execute(makeInput(id: id, name: "PEL"))
        }
    }
}
