//
//  ArchiveAccountTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct ArchiveAccountTests {

    private let repository = AccountDouble()
    private let useCase: ArchiveAccount
    private let accountId = UUID()

    init() {
        useCase = ArchiveAccount(repository: repository)
    }

    private func seedAccount() async throws {
        try await repository.save(TestData.account(id: accountId))
    }

    @Test("Marks the account as archived")
    func execute_archivesAccount() async throws {
        try await seedAccount()
        try await useCase.execute(id: accountId)
        let account = try await repository.fetch(by: accountId)
        #expect(account.isArchived)
    }

    @Test("Throws notFound for an unknown account")
    func execute_unknownId_throwsNotFound() async throws {
        await #expect(throws: AccountError.notFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
