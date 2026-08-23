//
//  GetTransactionsByCategoryTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct GetTransactionsByCategoryTests {

    private let repository = TransactionDouble()
    private let useCase: GetTransactionsByCategory
    private let profileId = UUID()

    init() {
        useCase = GetTransactionsByCategory(repository: repository)
    }

    @Test("Returns transactions matching the given category")
    func execute_returnsTransactionsForCategory() async throws {
        try await repository.save(TestData.transaction(profileId: profileId, category: .grocery))
        let result = try await useCase.execute(for: profileId, category: .grocery)
        #expect(result.count == 1)
    }

    @Test("Does not return transactions from another category")
    func execute_doesNotReturnTransactionsFromOtherCategory() async throws {
        try await repository.save(TestData.transaction(profileId: profileId, category: .grocery))
        let result = try await useCase.execute(for: profileId, category: .restaurant)
        #expect(result.isEmpty)
    }
}
