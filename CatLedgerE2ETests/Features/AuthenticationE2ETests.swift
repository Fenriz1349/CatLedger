//
//  AuthenticationE2ETests.swift
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
struct AuthenticationE2ETests {

    private let provider = AuthenticationProvider()

    init() {
        _ = TestHelperE2E.connectAuthToEmulator
    }

    @Test("Signs up, resolves the session, then deletes the registration")
    func signUp_resolveSession_deleteRegistration_roundTrips() async throws {
        let session = try await provider.signUp(email: TestHelperE2E.uniqueEmail(), password: TestData.password)
        #expect(!session.isAnonymous)

        let resolved = await provider.resolveSession()
        #expect(resolved?.registrationId == session.registrationId)

        try await provider.deleteRegistration()
        let afterDeletion = await provider.resolveSession()
        #expect(afterDeletion == nil)
    }

    @Test("Logs out, then logs back in with the same email and password")
    func logOut_login_resolveSession_roundTrips() async throws {
        let email = TestHelperE2E.uniqueEmail()
        let session = try await provider.signUp(email: email, password: TestData.password)

        try await provider.logOut()
        let afterLogOut = await provider.resolveSession()
        #expect(afterLogOut == nil)

        let loggedIn = try await provider.login(withEmail: email, password: TestData.password)
        #expect(loggedIn.registrationId == session.registrationId)

        let resolved = await provider.resolveSession()
        #expect(resolved?.registrationId == session.registrationId)

        try await provider.deleteRegistration()
    }

    @Test("Links an anonymous registration to a permanent email and password")
    func signUpAnonymously_linkAnonymousRegistration_becomesPermanent() async throws {
        let anonymousSession = try await provider.signUpAnonymously()
        #expect(anonymousSession.isAnonymous)

        let linkedSession = try await provider.linkAnonymousRegistration(
            toEmail: TestHelperE2E.uniqueEmail(),
            password: TestData.password
        )
        #expect(!linkedSession.isAnonymous)
        #expect(linkedSession.registrationId == anonymousSession.registrationId)

        try await provider.deleteRegistration()
    }

    @Test("Sends a password reset email for an existing account")
    func forgottenPassword_existingAccount_succeeds() async throws {
        let email = TestHelperE2E.uniqueEmail()
        _ = try await provider.signUp(email: email, password: TestData.password)

        try await provider.forgottenPassword(email: email)

        try await provider.deleteRegistration()
    }
}
