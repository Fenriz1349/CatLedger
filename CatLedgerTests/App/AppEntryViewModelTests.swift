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

    /// Stands in for `NetworkMonitor.verifyReachable`, so tests can force reachability to fail
    /// without a real network call.
    @MainActor
    private final class ReachabilitySpy {
        var errorToThrow: Error?

        func verifyReachable() async throws {
            if let errorToThrow { throw errorToThrow }
        }
    }

    private let authRepository = AuthenticationDouble()
    private let profileRepository = ProfileDouble()
    private let reachabilitySpy = ReachabilitySpy()
    private let viewModel: AppEntryViewModel

    init() {
        let reachability = reachabilitySpy
        let authenticationContainer = AuthenticationContainer(provider: authRepository)
        let profileContainer = ProfileContainer(provider: profileRepository)
        viewModel = AppEntryViewModel(
            resolveSession: ResolveSession(repository: authRepository),
            getCurrentProfile: GetCurrentProfile(repository: profileRepository),
            verifyReachable: reachability.verifyReachable,
            authenticationContainer: authenticationContainer,
            authenticationProfileContainer: AuthenticationProfileContainer(
                authentication: authenticationContainer,
                profile: profileContainer
            )
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

    @Test("Shows the offline screen when the backend can't be reached")
    func resolve_backendUnreachable_showsOffline() async {
        reachabilitySpy.errorToThrow = OfflineError.serverUnreachable

        await viewModel.resolve()

        #expect(viewModel.screen == .offline)
    }

    @Test("Reconnecting while offline re-resolves the screen")
    func connectivityChanged_reconnectingWhileOffline_resolvesAgain() async {
        reachabilitySpy.errorToThrow = OfflineError.serverUnreachable
        await viewModel.resolve()
        #expect(viewModel.screen == .offline)

        reachabilitySpy.errorToThrow = nil
        await viewModel.connectivityChanged(isConnected: true)

        #expect(viewModel.screen == .authentication)
    }

    @Test("Reconnecting while not offline does nothing")
    func connectivityChanged_reconnectingWhileNotOffline_doesNothing() async {
        await viewModel.resolve()
        #expect(viewModel.screen == .authentication)

        authRepository.sessionToResolve = AuthenticationSession(registrationId: UUID(), email: TestData.email)
        await viewModel.connectivityChanged(isConnected: true)

        #expect(viewModel.screen == .authentication)
    }

    @Test("Losing the network while on the authentication screen drops to offline")
    func connectivityChanged_disconnectingWhileOnAuthentication_showsOffline() async {
        await viewModel.resolve()
        #expect(viewModel.screen == .authentication)

        await viewModel.connectivityChanged(isConnected: false)

        #expect(viewModel.screen == .offline)
    }

    @Test("Losing the network while on the profile screen leaves it untouched")
    func connectivityChanged_disconnectingWhileOnProfile_staysOnProfile() async throws {
        let profile = TestData.profile()
        try await profileRepository.save(profile)
        authRepository.sessionToResolve = AuthenticationSession(
            registrationId: profile.registrationId,
            email: TestData.email
        )
        await viewModel.resolve()
        #expect(viewModel.screen == .profile(profile, email: TestData.email))

        await viewModel.connectivityChanged(isConnected: false)

        #expect(viewModel.screen == .profile(profile, email: TestData.email))
    }
}
