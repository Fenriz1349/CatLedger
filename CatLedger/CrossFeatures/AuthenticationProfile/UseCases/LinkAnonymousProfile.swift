//
//  LinkAnonymousProfile.swift
//  CatLedger
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation

/// Links the current anonymous registration to a permanent one, and updates the placeholder
/// profile created for the demo session with the real name provided at that point.
final class LinkAnonymousProfile {

    private let linkAnonymousRegistration: LinkAnonymousRegistration
    private let getCurrentProfile: GetCurrentProfile
    private let updateProfile: UpdateProfile

    /// - Parameters:
    ///   - linkAnonymousRegistration: The Authentication UseCase used to link the registration.
    ///   - getCurrentProfile: The Profile UseCase used to find the profile to update.
    ///   - updateProfile: The Profile UseCase used to persist the real name.
    init(
        linkAnonymousRegistration: LinkAnonymousRegistration,
        getCurrentProfile: GetCurrentProfile,
        updateProfile: UpdateProfile
    ) {
        self.linkAnonymousRegistration = linkAnonymousRegistration
        self.getCurrentProfile = getCurrentProfile
        self.updateProfile = updateProfile
    }

    /// - Parameters:
    ///   - firstName: The profile's real first name.
    ///   - lastName: The profile's real last name.
    ///   - email: The email address for both the registration and the profile.
    ///   - password: The password for the new permanent registration.
    /// - Returns: An updated, non-anonymous session.
    func execute(
        firstName: String,
        lastName: String,
        email: String,
        password: String
    ) async throws -> AuthenticationSession {
        let session = try await linkAnonymousRegistration.execute(email: email, password: password)
        let currentProfile = try await getCurrentProfile.execute(registrationId: session.registrationId)
        let input = UpdateProfileInput(
            id: currentProfile.id,
            registrationId: currentProfile.registrationId,
            firstName: firstName,
            lastName: lastName,
            photoURL: currentProfile.photoURL
        )
        try await updateProfile.execute(input)
        return session
    }
}
