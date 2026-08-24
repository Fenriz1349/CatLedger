//
//  UnarchiveAccountTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct UnarchiveAccountTests {

    private let repository = AccountDouble()
    private let useCase: UnarchiveAccount

    init() {
        useCase = UnarchiveAccount(repository: repository)
    }

    @Test("Restores the account to active status")
    func execute_unarchivesAccount() async throws {
        let account = TestData.account(isArchived: true)
        try await repository.save(account)
        try await useCase.execute(id: account.id)
        let updated = try await repository.fetch(by: account.id)
        #expect(!updated.isArchived)
    }

    @Test("Throws notFound for an unknown account")
    func execute_unknownId_throwsNotFound() async throws {
        await #expect(throws: AccountError.notFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
