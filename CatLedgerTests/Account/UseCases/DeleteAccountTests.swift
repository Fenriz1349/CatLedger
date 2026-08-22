//
//  DeleteAccountTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct DeleteAccountTests {

    private let repository = AccountDouble()
    private let useCase: DeleteAccount
    private let accountId = UUID()

    init() {
        useCase = DeleteAccount(repository: repository)
    }

    private func seedAccount() async throws {
        try await repository.save(TestData.account(id: accountId))
    }

    @Test("Removes the account record")
    func execute_existingId_accountDeleted() async throws {
        try await seedAccount()
        try await useCase.execute(id: accountId)
        await #expect(throws: AccountError.notFound) {
            try await repository.fetch(by: accountId)
        }
    }

    @Test("Throws notFound for an unknown account")
    func execute_unknownId_throwsNotFound() async throws {
        await #expect(throws: AccountError.notFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
