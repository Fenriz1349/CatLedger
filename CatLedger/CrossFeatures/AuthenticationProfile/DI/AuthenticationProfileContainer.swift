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

    /// - Parameters:
    ///   - authentication: The Authentication feature container to pull use cases from.
    ///   - profile: The Profile feature container to pull use cases from.
    init(authentication: AuthenticationContainer, profile: ProfileContainer) {
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

    /// - Returns: A configured AuthenticationProfileViewModel, wired with every use case it needs.
//    func makeViewModel() -> AuthenticationProfileViewModel {
//        AuthenticationProfileViewModel(
//            registerProfile: registerProfile,
//            registerAnonymousProfile: registerAnonymousProfile
//        )
//    }
}
