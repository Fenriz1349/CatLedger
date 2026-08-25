//
//  AuthE2ETests.swift
//  CatLedgerE2ETests
//
//  Created by Julien Cotte on 23/08/2026.
//

import Testing
@testable import CatLedger

/// End-to-end tests running `AuthenticationProvider` against a real Firebase Auth instance.
///
/// Requires the Firebase Local Emulator Suite running locally before executing this test plan:
///   `firebase emulators:start`
///
/// Run only this suite, not the default unit tests, either from Xcode (Product → Test Plan →
/// CatLedgerE2ETests, then ⌘U) or from the command line:
///   `xcodebuild test -project CatLedger.xcodeproj -scheme CatLedger -testPlan CatLedgerE2ETests \
///   -destination 'platform=iOS Simulator,name=iPhone 17'`
@Suite(.serialized, .timeLimit(.minutes(1)))
struct AuthE2ETests {

    private let provider = AuthenticationProvider()

    init() {
        _ = TestHelperE2E.connectAuthToEmulator
    }

    @Test("Signs up, resolves the session, then deletes the registration")
    func signUp_resolveSession_deleteRegistration_roundTrips() async throws {
        let session = try await provider.signUp(email: TestHelperE2E.uniqueEmail(), password: "password123")
        #expect(!session.isAnonymous)

        let resolved = await provider.resolveSession()
        #expect(resolved?.registrationId == session.registrationId)

        try await provider.deleteRegistration()
        let afterDeletion = await provider.resolveSession()
        #expect(afterDeletion == nil)
    }
}
