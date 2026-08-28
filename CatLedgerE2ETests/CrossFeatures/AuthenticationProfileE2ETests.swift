//
//  AuthenticationProfileE2ETests.swift
//  CatLedgerE2ETests
//
//  Created by Julien Cotte on 27/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

/// End-to-end tests running `RegisterProfile`/`RegisterAnonymousProfile`/`DeleteFirebaseRegistration`
/// against real Firebase Auth and Firestore instances, confirming the registration and its profile
/// are actually created and deleted together — not just individually, as already covered by
/// AuthenticationE2ETests/ProfileE2ETests.
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
struct AuthenticationProfileE2ETests {

    private let authenticationProvider = AuthenticationProvider()
    private let profileProvider = ProfileProvider()
    private let registerProfile: RegisterProfile
    private let registerAnonymousProfile: RegisterAnonymousProfile
    private let deleteFirebaseRegistration: DeleteFirebaseRegistration

    init() {
        _ = TestHelperE2E.connectAuthToEmulator
        _ = TestHelperE2E.connectFirestoreToEmulator
        registerProfile = RegisterProfile(
            signUp: SignUp(repository: authenticationProvider),
            createProfile: CreateProfile(repository: profileProvider)
        )
        registerAnonymousProfile = RegisterAnonymousProfile(
            signUpAnonymously: SignUpAnonymously(repository: authenticationProvider),
            createAnonymousProfile: CreateAnonymousProfile(repository: profileProvider)
        )
        deleteFirebaseRegistration = DeleteFirebaseRegistration(
            getCurrentProfile: GetCurrentProfile(repository: profileProvider),
            deleteProfile: DeleteProfile(repository: profileProvider),
            deleteRegistration: DeleteRegistration(repository: authenticationProvider)
        )
    }

    @Test("Registers a permanent account and its profile together")
    func execute_registerProfile_createsRegistrationAndProfile() async throws {
        let session = try await registerProfile.execute(
            firstName: TestData.firstName,
            lastName: TestData.lastName,
            email: TestHelperE2E.uniqueEmail(),
            password: TestData.password
        )
        #expect(!session.isAnonymous)

        let profile = try await profileProvider.fetch(by: session.registrationId)
        #expect(profile.firstName == TestData.firstName)
        #expect(profile.lastName == TestData.lastName)

        try await deleteFirebaseRegistration.execute(registrationId: session.registrationId)
    }

    @Test("Registers an anonymous account and its placeholder profile together")
    func execute_registerAnonymousProfile_createsRegistrationAndPlaceholderProfile() async throws {
        let session = try await registerAnonymousProfile.execute()
        #expect(session.isAnonymous)

        let profile = try await profileProvider.fetch(by: session.registrationId)
        #expect(profile.displayName.isEmpty)

        try await deleteFirebaseRegistration.execute(registrationId: session.registrationId)
    }

    @Test("Deletes the registration and its profile together")
    func execute_deleteFirebaseRegistration_deletesRegistrationAndProfile() async throws {
        let session = try await registerProfile.execute(
            firstName: TestData.firstName,
            lastName: TestData.lastName,
            email: TestHelperE2E.uniqueEmail(),
            password: TestData.password
        )

        try await deleteFirebaseRegistration.execute(registrationId: session.registrationId)

        await #expect(throws: ProfileError.notFound) {
            try await profileProvider.fetch(by: session.registrationId)
        }
        let resolved = await authenticationProvider.resolveSession()
        #expect(resolved == nil)
    }
}
