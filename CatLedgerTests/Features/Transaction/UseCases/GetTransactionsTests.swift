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
    private let profileId = UUID()

    init() {
        useCase = GetTransactions(repository: repository)
    }

    @Test("Returns all transactions belonging to the profile")
    func execute_returnsAllTransactionsForProfile() async throws {
        try await repository.save(TestData.transaction(profileId: profileId, label: "Courses"))
        try await repository.save(TestData.transaction(profileId: profileId, label: "Restaurant"))
        let result = try await useCase.execute(for: profileId)
        #expect(result.count == 2)
    }

    @Test("Does not return transactions belonging to another profile")
    func execute_doesNotReturnTransactionsFromOtherProfile() async throws {
        try await repository.save(TestData.transaction(profileId: profileId))
        let result = try await useCase.execute(for: UUID())
        #expect(result.isEmpty)
    }

    @Test("Returns an empty array when no transactions exist")
    func execute_noTransactions_returnsEmpty() async throws {
        let result = try await useCase.execute(for: profileId)
        #expect(result.isEmpty)
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = TransactionError.loadFailed
        await #expect(throws: TransactionError.loadFailed) {
            try await useCase.execute(for: profileId)
        }
    }
}
