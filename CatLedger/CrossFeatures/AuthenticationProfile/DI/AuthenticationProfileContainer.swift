//
//  AuthenticationProfileContainer.swift
//  CatLedger
//
//  Created by Julien Cotte on 27/08/2026.
//

import Foundation

/// Composition root for the Authentication/Profile cross-feature pairing: wires every use case
/// that orchestrates both features on top of the two feature containers that already exist.
/// Holds no business logic itself, and never builds a `Providing` implementation directly —
/// it only ever composes `AuthenticationContainer` and `ProfileContainer`.
final class AuthenticationProfileContainer {

    let registerProfile: RegisterProfile
    let registerAnonymousProfile: RegisterAnonymousProfile
    let linkAnonymousProfile: LinkAnonymousProfile
    let deleteFirebaseRegistration: DeleteFirebaseRegistration
    private let verifyReachable: () async throws -> Void

    /// - Parameters:
    ///   - authentication: The Authentication feature container to pull use cases from.
    ///   - profile: The Profile feature container to pull use cases from.
    ///   - verifyReachable: Confirms the backend can actually be reached, before any action.
    ///   Defaults to the shared `NetworkMonitor`; override with a double in tests.
    init(
        authentication: AuthenticationContainer,
        profile: ProfileContainer,
        verifyReachable: @escaping () async throws -> Void = NetworkMonitor.shared.verifyReachable
    ) {
        self.verifyReachable = verifyReachable
        registerProfile = RegisterProfile(
            signUp: authentication.signUp,
            createProfile: profile.createProfile
        )
        registerAnonymousProfile = RegisterAnonymousProfile(
            signUpAnonymously: authentication.signUpAnonymously,
            createAnonymousProfile: profile.createAnonymousProfile
        )
        linkAnonymousProfile = LinkAnonymousProfile(
            linkAnonymousRegistration: authentication.linkAnonymousRegistration,
            getCurrentProfile: profile.getCurrentProfile,
            updateProfile: profile.updateProfile
        )
        deleteFirebaseRegistration = DeleteFirebaseRegistration(
            getCurrentProfile: profile.getCurrentProfile,
            deleteProfile: profile.deleteProfile,
            deleteRegistration: authentication.deleteRegistration
        )
    }

    /// - Parameters:
    ///   - onAuthenticated: Called after a successful sign-up or demo entry, with the resulting session.
    ///   - onSessionEnded: Called after a successful deletion.
    /// - Returns: A configured AuthenticationProfileViewModel, wired with every use case it needs.
    func makeViewModel(
        onAuthenticated: @escaping (AuthenticationSession) async -> Void,
        onSessionEnded: @escaping () async -> Void
    ) -> AuthenticationProfileViewModel {
        AuthenticationProfileViewModel(
            registerProfile: registerProfile,
            registerAnonymousProfile: registerAnonymousProfile,
            deleteFirebaseRegistration: deleteFirebaseRegistration,
            onAuthenticated: onAuthenticated,
            onSessionEnded: onSessionEnded,
            verifyReachable: verifyReachable
        )
    }
}
