//
//  RegisterAnonymousProfile.swift
//  CatLedger
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation

/// Creates a new anonymous registration and its placeholder profile, for a demo session
/// that requires no email or password.
final class RegisterAnonymousProfile {

    private let signUpAnonymously: SignUpAnonymously
    private let createAnonymousProfile: CreateAnonymousProfile

    /// - Parameters:
    ///   - signUpAnonymously: The Authentication UseCase used to create the anonymous registration.
    ///   - createAnonymousProfile: The Profile UseCase used to create the placeholder profile.
    init(signUpAnonymously: SignUpAnonymously, createAnonymousProfile: CreateAnonymousProfile) {
        self.signUpAnonymously = signUpAnonymously
        self.createAnonymousProfile = createAnonymousProfile
    }

    /// - Returns: An anonymous session.
    func execute() async throws -> AuthenticationSession {
        let session = try await signUpAnonymously.execute()
        _ = try await createAnonymousProfile.execute(registrationId: session.registrationId)
        return session
    }
}
