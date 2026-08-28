//
//  AuthenticationDouble.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
@testable import CatLedger

/// Spy/stub test double implementation of AuthenticationProviding.
/// Used exclusively in unit tests to isolate UseCases from Firebase and local storage.
final class AuthenticationDouble: AuthenticationProviding {

    var sessionToReturn = AuthenticationSession(registrationId: UUID(), email: TestData.email)
    /// The value returned by resolveSession(). Defaults to nil (no stored session).
    var sessionToResolve: AuthenticationSession?

    /// Tracks whether deleteRegistration() was called.
    var didCallDeleteRegistration = false

    /// Tracks whether signOut() was called.
    var didCallSignOut = false

    /// Set this to force any throwing method to throw a specific error.
    var errorToThrow: Error?

    func resolveSession() async -> AuthenticationSession? {
        sessionToResolve
    }

    func login(withEmail email: String, password: String) async throws -> AuthenticationSession {
        if let error = errorToThrow { throw error }
        return sessionToReturn
    }

    func signUp(email: String, password: String) async throws -> AuthenticationSession {
        if let error = errorToThrow { throw error }
        return sessionToReturn
    }

    func signInAnonymously() async throws -> AuthenticationSession {
        if let error = errorToThrow { throw error }
        return sessionToReturn
    }

    func signOut() async throws {
        if let error = errorToThrow { throw error }
        didCallSignOut = true
    }

    func deleteRegistration() async throws {
        if let error = errorToThrow { throw error }
        didCallDeleteRegistration = true
    }

    func linkAnonymousRegistration(toEmail email: String, password: String) async throws -> AuthenticationSession {
        if let error = errorToThrow { throw error }
        return sessionToReturn
    }

    func resetPassword(email: String) async throws {
        if let error = errorToThrow { throw error }
    }
}
