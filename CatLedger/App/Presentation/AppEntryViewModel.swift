//
//  AppEntryViewModel.swift
//  CatLedger
//
//  Created by Julien Cotte on 27/08/2026.
//

import Foundation

/// Decides which screen to show at launch: resolves any existing Authentication session, then
/// loads the profile that session owns.
@Observable
@MainActor
final class AppEntryViewModel {

    /// The screen AppEntryView should show once resolution completes. `nil` while resolving.
    enum Screen: Equatable {
        case authentication
        case profile(Profile, email: String?)
    }

    private(set) var screen: Screen?

    private let resolveSession: ResolveSession
    private let getCurrentProfile: GetCurrentProfile

    /// - Parameters:
    ///   - resolveSession: Use case for resolving any existing Authentication session.
    ///   - getCurrentProfile: Use case for loading the profile that session owns.
    init(resolveSession: ResolveSession, getCurrentProfile: GetCurrentProfile) {
        self.resolveSession = resolveSession
        self.getCurrentProfile = getCurrentProfile
    }

    /// Resolves the current session and, if one exists, its profile — deciding which screen to show.
    /// Falls back to the Authentication screen if a session exists but its profile can't be loaded.
    func resolve() async {
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
}
