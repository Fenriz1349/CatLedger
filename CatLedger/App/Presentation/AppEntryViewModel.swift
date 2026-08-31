//
//  AppEntryViewModel.swift
//  CatLedger
//
//  Created by Julien Cotte on 27/08/2026.
//

import Foundation

/// Decides which screen to show at launch: verifies the backend is reachable, resolves any
/// existing Authentication session, then loads the profile that session owns.
@Observable
@MainActor
final class AppEntryViewModel {

    /// The screen AppEntryView should show once resolution completes. `nil` while resolving.
    enum Screen: Equatable {
        case authentication
        case profile(Profile, email: String?)
        case offline
    }

    private(set) var screen: Screen?

    private let resolveSession: ResolveSession
    private let getCurrentProfile: GetCurrentProfile
    private let verifyReachable: () async throws -> Void

    /// - Parameters:
    ///   - resolveSession: Use case for resolving any existing Authentication session.
    ///   - getCurrentProfile: Use case for loading the profile that session owns.
    ///   - verifyReachable: Confirms the backend can actually be reached, before anything else.
    init(
        resolveSession: ResolveSession,
        getCurrentProfile: GetCurrentProfile,
        verifyReachable: @escaping () async throws -> Void
    ) {
        self.resolveSession = resolveSession
        self.getCurrentProfile = getCurrentProfile
        self.verifyReachable = verifyReachable
    }

    /// Verifies reachability, then resolves the current session and its profile — deciding which
    /// screen to show. Falls back to the Authentication screen if a session exists but its
    /// profile can't be loaded, or to the Offline screen if the backend can't be reached.
    func resolve() async {
        do {
            try await verifyReachable()
        } catch {
            screen = .offline
            return
        }
        guard let session = await resolveSession.execute() else {
            screen = .authentication
            return
        }
        do {
            let profile = try await getCurrentProfile.execute(registrationId: session.registrationId)
            screen = .profile(profile, email: session.email)
        } catch {
            screen = .authentication
        }
    }

    /// Keeps the Authentication/Offline pair aligned with the network: drops from Authentication
    /// to Offline as soon as the network goes down, and re-resolves as soon as it's back.
    /// The Profile screen is untouched either way — it doesn't need network just to be displayed.
    func connectivityChanged(isConnected: Bool) async {
        if isConnected {
            guard screen == .offline else { return }
            await resolve()
        } else if screen == .authentication {
            screen = .offline
        }
    }
}
