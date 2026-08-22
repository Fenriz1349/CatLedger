//
//  GetAccountTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct GetAccountTests {

    private let repository = AccountDouble()
    private let useCase: GetAccount

    init() {
        useCase = GetAccount(repository: repository)
    }

    /// Seeds and returns an account with a known id.
    private func seedAccount() async throws -> UUID {
        let account = TestData.account()
        try await repository.save(account)
        return account.id
    }

    @Test("Returns the account matching an existing id")
    func execute_existingId_returnsAccount() async throws {
        let id = try await seedAccount()
        let result = try await useCase.execute(id: id)
        #expect(result.id == id)
    }

    @Test("Returns the account with its expected name")
    func execute_existingId_returnsCorrectName() async throws {
        let id = try await seedAccount()
        let result = try await useCase.execute(id: id)
        #expect(result.name == "Compte courant")
    }

    @Test("Throws notFound when no account matches the id")
    func execute_unknownId_throwsNotFound() async throws {
        await #expect(throws: AccountError.notFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
