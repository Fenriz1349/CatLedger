//
//  GetTransactionsByDateRangeTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct GetTransactionsByDateRangeTests {

    private let repository = TransactionDouble()
    private let useCase: GetTransactionsByDateRange
    private let profileId = UUID()

    init() {
        useCase = GetTransactionsByDateRange(repository: repository)
    }

    @Test("Returns transactions within the date range")
    func execute_returnsTransactionsWithinRange() async throws {
        let calendar = Calendar.current
        let now = Date()
        try await repository.save(TestData.transaction(profileId: profileId, date: now))
        let result = try await useCase.execute(
            for: profileId,
            from: calendar.date(byAdding: .day, value: -1, to: now)!,
            to: calendar.date(byAdding: .day, value: 1, to: now)!
        )
        #expect(result.count == 1)
    }

    @Test("Does not return transactions outside the date range")
    func execute_doesNotReturnTransactionsOutsideRange() async throws {
        let calendar = Calendar.current
        let now = Date()
        try await repository.save(TestData.transaction(profileId: profileId, date: now))
        let result = try await useCase.execute(
            for: profileId,
            from: calendar.date(byAdding: .day, value: -10, to: now)!,
            to: calendar.date(byAdding: .day, value: -5, to: now)!
        )
        #expect(result.isEmpty)
    }

    @Test("Throws invalidDateRange when from is after to")
    func execute_fromAfterTo_throwsInvalidDateRange() async throws {
        let now = Date()
        let earlier = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        await #expect(throws: TransactionError.invalidDateRange) {
            try await useCase.execute(for: profileId, from: now, to: earlier)
        }
    }
}
