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

    private let logInAnonymously: LogInAnonymously
    private let createAnonymousProfile: CreateAnonymousProfile

    /// - Parameters:
    ///   - logInAnonymously: The Authentication UseCase used to create the anonymous registration.
    ///   - createAnonymousProfile: The Profile UseCase used to create the placeholder profile.
    init(logInAnonymously: LogInAnonymously, createAnonymousProfile: CreateAnonymousProfile) {
        self.logInAnonymously = logInAnonymously
        self.createAnonymousProfile = createAnonymousProfile
    }

    /// - Returns: An anonymous session.
    func execute() async throws -> AuthenticationSession {
        let session = try await logInAnonymously.execute()
        _ = try await createAnonymousProfile.execute(registrationId: session.registrationId)
        return session
    }
}
