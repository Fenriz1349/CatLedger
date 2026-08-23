//
//  ExpireAnonymousProfile.swift
//  CatLedger
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation

/// Checks whether the current anonymous session has exceeded its validity period.
/// If so, deletes its profile while the registration can still authenticate the request,
/// then deletes the registration itself.
final class ExpireAnonymousProfile {

    private let isAnonymousSessionExpired: IsAnonymousSessionExpired
    private let getCurrentProfile: GetCurrentProfile
    private let deleteProfile: DeleteProfile
    private let expireAnonymousSession: ExpireAnonymousSession

    /// - Parameters:
    ///   - isAnonymousSessionExpired: The Authentication UseCase used to check the session.
    ///   - getCurrentProfile: The Profile UseCase used to find the profile to delete.
    ///   - deleteProfile: The Profile UseCase used to delete it.
    ///   - expireAnonymousSession: The Authentication UseCase used to delete the registration.
    init(
        isAnonymousSessionExpired: IsAnonymousSessionExpired,
        getCurrentProfile: GetCurrentProfile,
        deleteProfile: DeleteProfile,
        expireAnonymousSession: ExpireAnonymousSession
    ) {
        self.isAnonymousSessionExpired = isAnonymousSessionExpired
        self.getCurrentProfile = getCurrentProfile
        self.deleteProfile = deleteProfile
        self.expireAnonymousSession = expireAnonymousSession
    }

    /// Expires the anonymous session and its profile if it has exceeded its validity period.
    /// - Parameter registrationId: The registration whose profile to delete if the session is expired.
    /// - Returns: `true` if the session was expired and deleted, `false` if still valid.
    func execute(registrationId: UUID) async throws -> Bool {
        guard isAnonymousSessionExpired.execute() else { return false }
        let profile = try await getCurrentProfile.execute(registrationId: registrationId)
        try await deleteProfile.execute(id: profile.id)
        _ = await expireAnonymousSession.execute()
        return true
    }
}
