//
//  DeleteFirebaseRegistration.swift
//  CatLedger
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation

/// Deletes the current profile, then the registration that owns it.
/// The profile is deleted first, while the registration can still authenticate the request.
final class DeleteFirebaseRegistration {

    private let getCurrentProfile: GetCurrentProfile
    private let deleteProfile: DeleteProfile
    private let deleteRegistration: DeleteRegistration

    /// - Parameters:
    ///   - getCurrentProfile: The Profile UseCase used to find the profile to delete.
    ///   - deleteProfile: The Profile UseCase used to delete it.
    ///   - deleteRegistration: The Authentication UseCase used to delete the registration.
    init(getCurrentProfile: GetCurrentProfile, deleteProfile: DeleteProfile, deleteRegistration: DeleteRegistration) {
        self.getCurrentProfile = getCurrentProfile
        self.deleteProfile = deleteProfile
        self.deleteRegistration = deleteRegistration
    }

    /// - Parameter registrationId: The registration whose profile and registration to delete.
    func execute(registrationId: UUID) async throws {
        let profile = try await getCurrentProfile.execute(registrationId: registrationId)
        try await deleteProfile.execute(id: profile.id)
        try await deleteRegistration.execute()
    }
}
