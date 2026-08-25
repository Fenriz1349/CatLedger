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

    init() {
        useCase = DeleteAccount(repository: repository)
    }

    @Test("Removes the account record")
    func execute_existingId_accountDeleted() async throws {
        let account = TestData.account()
        try await repository.save(account)
        try await useCase.execute(id: account.id)
        await #expect(throws: AccountError.notFound) {
            try await repository.fetch(by: account.id)
        }
    }

    @Test("Throws notFound for an unknown account")
    func execute_unknownId_throwsNotFound() async throws {
        await #expect(throws: AccountError.notFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
