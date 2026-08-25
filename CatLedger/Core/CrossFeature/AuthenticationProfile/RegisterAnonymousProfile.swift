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

    private let signInAnonymously: SignInAnonymously
    private let createAnonymousProfile: CreateAnonymousProfile

    /// - Parameters:
    ///   - signInAnonymously: The Authentication UseCase used to create the anonymous registration.
    ///   - createAnonymousProfile: The Profile UseCase used to create the placeholder profile.
    init(signInAnonymously: SignInAnonymously, createAnonymousProfile: CreateAnonymousProfile) {
        self.signInAnonymously = signInAnonymously
        self.createAnonymousProfile = createAnonymousProfile
    }

    /// - Returns: An anonymous session.
    func execute() async throws -> AuthSession {
        let session = try await signInAnonymously.execute()
        _ = try await createAnonymousProfile.execute(registrationId: session.registrationId)
        return session
    }
}
