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

    init() {
        useCase = ArchiveAccount(repository: repository)
    }

    @Test("Marks the account as archived")
    func execute_archivesAccount() async throws {
        let account = TestData.account()
        try await repository.save(account)
        try await useCase.execute(id: account.id)
        let updated = try await repository.fetch(by: account.id)
        #expect(updated.isArchived)
    }

    @Test("Throws notFound for an unknown account")
    func execute_unknownId_throwsNotFound() async throws {
        await #expect(throws: AccountError.notFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
