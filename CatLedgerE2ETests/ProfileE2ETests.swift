//
//  ProfileE2ETests.swift
//  CatLedgerE2ETests
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

/// End-to-end tests running `ProfileProvider` against a real Firestore instance.
///
/// Requires the Firebase Local Emulator Suite running locally before executing this test plan:
///   `firebase emulators:start`
///
/// Run only this suite, not the default unit tests, either from Xcode (Product → Test Plan →
/// CatLedgerE2ETests, then ⌘U) or from the command line:
///   `xcodebuild test -project CatLedger.xcodeproj -scheme CatLedger -testPlan CatLedgerE2ETests \
///   -destination 'platform=iOS Simulator,name=iPhone 17'`
struct ProfileE2ETests {

    private let provider = ProfileProvider()

    init() {
        _ = TestDataE2E.connectFirestoreToEmulator
    }

    @Test("Saves, fetches, updates, then deletes a profile")
    func save_fetch_update_delete_roundTrips() async throws {
        let registrationId = UUID()
        let profile = TestDataE2E.profile(registrationId: registrationId)

        try await provider.save(profile)
        let fetched = try await provider.fetch(by: registrationId)
        #expect(fetched.id == profile.id)
        #expect(fetched.firstName == "Bruce")

        let updated = TestDataE2E.profile(
            id: profile.id,
            registrationId: registrationId,
            firstName: "Richard",
            lastName: "Grayson"
        )
        try await provider.update(updated)
        let refetched = try await provider.fetch(by: registrationId)
        #expect(refetched.firstName == "Richard")

        try await provider.delete(by: profile.id)
        await #expect(throws: ProfileError.notFound) {
            try await provider.fetch(by: registrationId)
        }
    }
}
