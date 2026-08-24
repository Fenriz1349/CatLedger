//
//  InstitutionE2ETests.swift
//  CatLedgerE2ETests
//
//  Created by Julien Cotte on 24/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

/// End-to-end tests running `InstitutionProvider` against a real Firestore instance.
///
/// Requires the Firebase Local Emulator Suite running locally before executing this test plan:
///   `firebase emulators:start`
///
/// Run only this suite, not the default unit tests, either from Xcode (Product → Test Plan →
/// CatLedgerE2ETests, then ⌘U) or from the command line:
///   `xcodebuild test -project CatLedger.xcodeproj -scheme CatLedger -testPlan CatLedgerE2ETests \
///   -destination 'platform=iOS Simulator,name=iPhone 17'`
struct InstitutionE2ETests {

    private let provider = InstitutionProvider()

    init() {
        _ = TestHelperE2E.connectFirestoreToEmulator
    }

    @Test("Saves, fetches, archives, updates, then deletes an institution")
    func save_fetch_archive_update_delete_roundTrips() async throws {
        let profileId = UUID()
        let institution = TestData.institution(profileId: profileId)

        try await provider.save(institution)
        let fetched = try await provider.fetch(by: institution.id)
        #expect(fetched.name == "BNP Paribas")

        let all = try await provider.fetchAll(for: profileId)
        #expect(all.map(\.id) == [institution.id])

        try await provider.archive(by: institution.id)
        let archived = try await provider.fetch(by: institution.id)
        #expect(archived.isArchived)

        try await provider.unarchive(by: institution.id)
        let unarchived = try await provider.fetch(by: institution.id)
        #expect(!unarchived.isArchived)

        let updated = TestData.institution(id: institution.id, profileId: profileId, name: "Caisse d'Épargne")
        try await provider.update(updated)
        let refetched = try await provider.fetch(by: institution.id)
        #expect(refetched.name == "Caisse d'Épargne")

        try await provider.delete(by: institution.id)
        await #expect(throws: InstitutionError.notFound) {
            try await provider.fetch(by: institution.id)
        }
    }
}
