//
//  GetTransactionTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct GetTransactionTests {

    private let repository = TransactionDouble()
    private let useCase: GetTransaction

    init() {
        useCase = GetTransaction(repository: repository)
    }

    @Test("Returns the transaction matching an existing id")
    func execute_existingId_returnsTransaction() async throws {
        let transaction = TestData.transaction()
        try await repository.save(transaction)
        let result = try await useCase.execute(id: transaction.id)
        #expect(result.id == transaction.id)
    }

    @Test("Throws notFound when no transaction matches the id")
    func execute_unknownId_throwsNotFound() async throws {
        await #expect(throws: TransactionError.notFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
