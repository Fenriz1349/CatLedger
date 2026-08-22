//
//  DeleteTransactionTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct DeleteTransactionTests {

    private let repository = TransactionDouble()
    private let useCase: DeleteTransaction

    init() {
        useCase = DeleteTransaction(repository: repository)
    }

    @Test("Removes the transaction record")
    func execute_existingId_transactionDeleted() async throws {
        let transaction = TestData.transaction()
        try await repository.save(transaction)
        try await useCase.execute(id: transaction.id)
        await #expect(throws: TransactionError.notFound) {
            try await repository.fetch(by: transaction.id)
        }
    }

    @Test("Throws notFound for an unknown transaction")
    func execute_unknownId_throwsNotFound() async throws {
        await #expect(throws: TransactionError.notFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
