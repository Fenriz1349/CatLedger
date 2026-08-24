//
//  TransactionE2ETests.swift
//  CatLedgerE2ETests
//
//  Created by Julien Cotte on 24/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

/// End-to-end tests running `TransactionProvider` against a real Firestore instance.
///
/// Requires the Firebase Local Emulator Suite running locally before executing this test plan:
///   `firebase emulators:start`
///
/// Run only this suite, not the default unit tests, either from Xcode (Product → Test Plan →
/// CatLedgerE2ETests, then ⌘U) or from the command line:
///   `xcodebuild test -project CatLedger.xcodeproj -scheme CatLedger -testPlan CatLedgerE2ETests \
///   -destination 'platform=iOS Simulator,name=iPhone 17'`
struct TransactionE2ETests {

    private let provider = TransactionProvider()

    init() {
        _ = TestHelperE2E.connectFirestoreToEmulator
    }

    @Test("Saves, fetches, filters, updates, then deletes a transaction")
    func save_fetch_filter_update_delete_roundTrips() async throws {
        let transaction = TestData.transaction()

        try await provider.save(transaction)
        let fetched = try await provider.fetch(by: transaction.id)
        #expect(fetched.label == transaction.label)

        let all = try await provider.fetchAll(for: transaction.profileId)
        #expect(all.map(\.id) == [transaction.id])

        let byAccount = try await provider.fetchAllByAccount(
            for: transaction.profileId,
            accountId: transaction.splits[0].accountId
        )
        #expect(byAccount.map(\.id) == [transaction.id])

        let byCategory = try await provider.fetchAllByCategory(
            for: transaction.profileId,
            category: transaction.category
        )
        #expect(byCategory.map(\.id) == [transaction.id])

        let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: transaction.date)
        let dayAfter = Calendar.current.date(byAdding: .day, value: 1, to: transaction.date)
        let byDateRange = try await provider.fetchAllByDateRange(
            for: transaction.profileId,
            from: try #require(dayBefore),
            to: try #require(dayAfter)
        )
        #expect(byDateRange.map(\.id) == [transaction.id])

        let update = TestData.updateTransactionInput(
            id: transaction.id,
            profileId: transaction.profileId,
            splits: transaction.splits
        )
        let updated = Transaction(
            id: update.id,
            profileId: update.profileId,
            label: update.label,
            date: update.date,
            totalAmount: update.totalAmount,
            note: update.note,
            isExpense: update.isExpense,
            category: update.category,
            splits: update.splits,
            isChecked: transaction.isChecked
        )
        try await provider.update(updated)
        let refetched = try await provider.fetch(by: transaction.id)
        #expect(refetched.label == update.label)

        try await provider.delete(by: transaction.id)
        await #expect(throws: TransactionError.notFound) {
            try await provider.fetch(by: transaction.id)
        }
    }
}
