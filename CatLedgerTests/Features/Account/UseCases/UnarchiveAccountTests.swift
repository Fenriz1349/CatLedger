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
    private let accountId = UUID()

    init() {
        useCase = UnarchiveAccount(repository: repository)
    }

    private func seedArchivedAccount() async throws {
        try await repository.save(TestData.account(id: accountId, isArchived: true))
    }

    @Test("Restores the account to active status")
    func execute_unarchivesAccount() async throws {
        try await seedArchivedAccount()
        try await useCase.execute(id: accountId)
        let account = try await repository.fetch(by: accountId)
        #expect(!account.isArchived)
    }

    @Test("Throws notFound for an unknown account")
    func execute_unknownId_throwsNotFound() async throws {
        await #expect(throws: AccountError.notFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
