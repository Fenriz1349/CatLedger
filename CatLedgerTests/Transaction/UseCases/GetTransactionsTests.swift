//
//  GetTransactionsTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct GetTransactionsTests {

    private let repository = TransactionDouble()
    private let useCase: GetTransactions
    private let userId = UUID()

    init() {
        useCase = GetTransactions(repository: repository)
    }

    @Test("Returns all transactions belonging to the user")
    func execute_returnsAllTransactionsForUser() async throws {
        try await repository.save(TestData.transaction(userId: userId, label: "Courses"))
        try await repository.save(TestData.transaction(userId: userId, label: "Restaurant"))
        let result = try await useCase.execute(for: userId)
        #expect(result.count == 2)
    }

    @Test("Does not return transactions belonging to another user")
    func execute_doesNotReturnTransactionsFromOtherUser() async throws {
        try await repository.save(TestData.transaction(userId: userId))
        let result = try await useCase.execute(for: UUID())
        #expect(result.isEmpty)
    }

    @Test("Returns an empty array when no transactions exist")
    func execute_noTransactions_returnsEmpty() async throws {
        let result = try await useCase.execute(for: userId)
        #expect(result.isEmpty)
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = TransactionError.loadFailed
        await #expect(throws: TransactionError.loadFailed) {
            try await useCase.execute(for: userId)
        }
    }
}
