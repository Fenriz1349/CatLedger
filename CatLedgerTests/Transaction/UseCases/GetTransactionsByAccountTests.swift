//
//  GetTransactionsByAccountTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct GetTransactionsByAccountTests {

    private let repository = TransactionDouble()
    private let useCase: GetTransactionsByAccount
    private let profileId = UUID()
    private let accountId = UUID()

    init() {
        useCase = GetTransactionsByAccount(repository: repository)
    }

    @Test("Returns transactions holding a split on the given account")
    func execute_returnsTransactionsForAccount() async throws {
        let split = TestData.transactionSplit(accountId: accountId, amount: 10)
        try await repository.save(TestData.transaction(profileId: profileId, splits: [split]))
        let result = try await useCase.execute(for: profileId, accountId: accountId)
        #expect(result.count == 1)
    }

    @Test("Does not return transactions on another account")
    func execute_doesNotReturnTransactionsFromOtherAccount() async throws {
        try await repository.save(TestData.transaction(profileId: profileId))
        let result = try await useCase.execute(for: profileId, accountId: accountId)
        #expect(result.isEmpty)
    }
}
