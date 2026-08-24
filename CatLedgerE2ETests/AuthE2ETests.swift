//
//  AuthE2ETests.swift
//  AuthE2ETests
//
//  Created by Julien Cotte on 23/08/2026.
//

import Testing
@testable import CatLedger

/// End-to-end tests running `AuthProvider` against a real Firebase Auth instance.
///
/// Requires the Firebase Local Emulator Suite running locally before executing this test plan:
///   `firebase emulators:start`
///
/// Run only this suite, not the default unit tests, either from Xcode (Product → Test Plan →
/// CatLedgerE2ETests, then ⌘U) or from the command line:
///   `xcodebuild test -project CatLedger.xcodeproj -scheme CatLedger -testPlan CatLedgerE2ETests \
///   -destination 'platform=iOS Simulator,name=iPhone 17'`
///
/// Tests run serialized: `Auth.auth()` is a process-wide singleton, so running them concurrently
/// (Swift Testing's default) lets one test's sign-in/deletion interleave with another's session read.
@Suite(.serialized)
struct AuthE2ETests {

    private let provider = AuthProvider()

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

    @Test("Signs in anonymously, then expiring the session clears it")
    func signInAnonymously_expireAnonymousSession_clearsSession() async throws {
        let session = try await provider.signInAnonymously()
        #expect(session.isAnonymous)

        await provider.expireAnonymousSession()
        let afterExpiry = await provider.resolveSession()
        #expect(afterExpiry == nil)
    }
}
