//
//  RegisterProfile.swift
//  CatLedger
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation

/// Creates a new permanent registration and its associated profile.
final class RegisterProfile {

    private let signUp: SignUp
    private let createProfile: CreateProfile

    /// - Parameters:
    ///   - signUp: The Authentication UseCase used to create the registration.
    ///   - createProfile: The Profile UseCase used to create the associated profile.
    init(signUp: SignUp, createProfile: CreateProfile) {
        self.signUp = signUp
        self.createProfile = createProfile
    }

    /// - Parameters:
    ///   - firstName: The profile's first name.
    ///   - lastName: The profile's last name.
    ///   - email: The email address for both the registration and the profile.
    ///   - password: The registration's password.
    /// - Returns: A session for the newly created registration.
    func execute(firstName: String, lastName: String, email: String, password: String) async throws -> AuthSession {
        let session = try await signUp.execute(email: email, password: password)
        _ = try await createProfile.execute(firstName: firstName, lastName: lastName, email: email)
        return session
    }
}
