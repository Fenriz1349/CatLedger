//
//  AccountE2ETests.swift
//  CatLedgerE2ETests
//
//  Created by Julien Cotte on 24/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

/// End-to-end tests running `AccountProvider` against a real Firestore instance.
///
/// The CatLedger scheme's Test pre/post-actions start and stop the Firebase Local Emulator Suite
/// automatically. Running outside that scheme requires starting it manually first:
///   `firebase emulators:start`
///
/// Run only this suite, not the default unit tests, either from Xcode (Product → Test Plan →
/// CatLedgerE2ETests, then ⌘U) or from the command line:
///   `xcodebuild test -project CatLedger.xcodeproj -scheme CatLedger -testPlan CatLedgerE2ETests \
///   -destination 'platform=iOS Simulator,name=iPhone 17'`
@MainActor
@Suite(.serialized, .timeLimit(.minutes(1)))
struct AccountE2ETests {

    private let provider = AccountProvider()

    init() {
        _ = TestHelperE2E.connectFirestoreToEmulator
    }

    @Test("Saves, fetches, archives, updates, then deletes an account")
    func save_fetch_archive_update_delete_roundTrips() async throws {
        let account = TestData.account()
        try await provider.save(account)

        let fetched = try await provider.fetch(by: account.id)
        #expect(fetched.name == account.name)

        let all = try await provider.fetchAll(for: account.institutionId)
        #expect(all.map(\.id) == [account.id])

        let active = try await provider.fetchAllActive(for: account.institutionId)
        #expect(active.map(\.id) == [account.id])

        try await provider.archive(by: account.id)
        let archived = try await provider.fetchAllArchived(for: account.institutionId)
        #expect(archived.map(\.id) == [account.id])
        let stillActive = try await provider.fetchAllActive(for: account.institutionId)
        #expect(stillActive.isEmpty)

        try await provider.unarchive(by: account.id)
        let unarchived = try await provider.fetch(by: account.id)
        #expect(!unarchived.isArchived)

        let update = TestData.updateAccountInput(id: account.id, institutionId: account.institutionId)
        let updated = TestData.account(
            id: update.id,
            institutionId: update.institutionId,
            name: update.name,
            category: update.category
        )
        try await provider.update(updated)
        let refetched = try await provider.fetch(by: account.id)
        #expect(refetched.name == update.name)

        try await provider.delete(by: account.id)
        await #expect(throws: AccountError.notFound) {
            try await provider.fetch(by: account.id)
        }
    }
}
