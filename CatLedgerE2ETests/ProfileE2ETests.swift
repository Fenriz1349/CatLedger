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
@MainActor
@Suite(.serialized, .timeLimit(.minutes(1)))
struct ProfileE2ETests {

    private let provider = ProfileProvider()

    init() {
        _ = TestHelperE2E.connectFirestoreToEmulator
    }

    @Test("Saves, fetches, updates, then deletes a profile")
    func save_fetch_update_delete_roundTrips() async throws {
        let profile = TestData.profile()
        try await provider.save(profile)

        let fetched = try await provider.fetch(by: profile.registrationId)
        #expect(fetched.id == profile.id)
        #expect(fetched.firstName == profile.firstName)

        let update = TestData.updateProfileInput(id: profile.id, registrationId: profile.registrationId)
        let updated = TestData.profile(
            id: update.id,
            registrationId: update.registrationId,
            firstName: update.firstName,
            lastName: update.lastName,
            photoURL: update.photoURL
        )
        try await provider.update(updated)
        let refetched = try await provider.fetch(by: profile.registrationId)
        #expect(refetched.firstName == update.firstName)

        try await provider.delete(by: profile.id)
        await #expect(throws: ProfileError.notFound) {
            try await provider.fetch(by: profile.registrationId)
        }
    }
}
