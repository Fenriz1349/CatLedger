//
//  ProfileContainer.swift
//  CatLedger
//
//  Created by Julien Cotte on 25/08/2026.
//

import Foundation

/// Composition root for the Profile feature: builds the concrete `ProfileProviding`
/// implementation once, then wires every Profile use case on top of it.
/// Holds no business logic itself — Presentation code reads its properties to get
/// use cases already wired and ready to inject into view models.
final class ProfileContainer {

    let provider: ProfileProviding

    let getCurrentProfile: GetCurrentProfile
    let createProfile: CreateProfile
    let createAnonymousProfile: CreateAnonymousProfile
    let updateProfile: UpdateProfile
    let deleteProfile: DeleteProfile
    private let verifyReachable: () async throws -> Void

    /// - Parameters:
    ///   - provider: The Profile provider to wire every use case to.
    ///   Defaults to the Firebase-backed implementation; override with a double in tests.
    ///   - verifyReachable: Confirms the backend can actually be reached, before any write.
    ///   Defaults to the shared `NetworkMonitor`; override with a double in tests.
    init(
        provider: ProfileProviding = ProfileProvider(),
        verifyReachable: @escaping () async throws -> Void = NetworkMonitor.shared.verifyReachable
    ) {
        self.provider = provider
        self.verifyReachable = verifyReachable
        getCurrentProfile = GetCurrentProfile(repository: provider)
        createProfile = CreateProfile(repository: provider)
        createAnonymousProfile = CreateAnonymousProfile(repository: provider)
        updateProfile = UpdateProfile(repository: provider)
        deleteProfile = DeleteProfile(repository: provider)
    }

    /// - Parameter registrationId: The registration the new profile will belong to.
    /// - Returns: A configured ProfileViewModel, in create mode, wired with every use case it needs.
    func makeViewModel(registrationId: UUID) -> ProfileViewModel {
        ProfileViewModel(
            context: .create(registrationId: registrationId),
            createProfile: createProfile,
            updateProfile: updateProfile,
            verifyReachable: verifyReachable
        )
    }

    /// - Parameter profile: The profile to edit, pre-filling the form.
    /// - Returns: A configured ProfileViewModel, in edit mode, wired with every use case it needs.
    func makeViewModel(profile: Profile) -> ProfileViewModel {
        ProfileViewModel(
            context: .existing(profile),
            createProfile: createProfile,
            updateProfile: updateProfile,
            verifyReachable: verifyReachable
        )
    }
}
