//
//  AppEntryViewModelTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 27/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

@MainActor
struct AppEntryViewModelTests {

    private let authRepository = AuthenticationDouble()
    private let profileRepository = ProfileDouble()
    private let viewModel: AppEntryViewModel

    init() {
        viewModel = AppEntryViewModel(
            resolveSession: ResolveSession(repository: authRepository),
            getCurrentProfile: GetCurrentProfile(repository: profileRepository)
        )
    }

    @Test("Shows the authentication screen when no session is stored")
    func resolve_noStoredSession_showsAuthentication() async {
        await viewModel.resolve()
        #expect(viewModel.screen == .authentication)
    }

    @Test("Shows the profile screen when a session and its profile both exist")
    func resolve_sessionAndProfileExist_showsProfile() async throws {
        let profile = TestData.profile()
        try await profileRepository.save(profile)
        authRepository.sessionToResolve = AuthenticationSession(
            registrationId: profile.registrationId,
            email: TestData.email
        )

        await viewModel.resolve()

        #expect(viewModel.screen == .profile(profile, email: TestData.email))
    }

    @Test("Falls back to the authentication screen when the session's profile can't be found")
    func resolve_sessionWithoutProfile_fallsBackToAuthentication() async {
        authRepository.sessionToResolve = AuthenticationSession(registrationId: UUID(), email: TestData.email)

        await viewModel.resolve()

        #expect(viewModel.screen == .authentication)
    }
}
