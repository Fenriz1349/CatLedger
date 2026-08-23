//
//  AuthenticationDouble.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
@testable import CatLedger

/// Spy/stub test double implementation of AuthProviding.
/// Used exclusively in unit tests to isolate UseCases from Firebase and local storage.
final class AuthenticationDouble: AuthProviding {

    var sessionToReturn = AuthSession(profileId: UUID(), isAnonymous: false)
    /// The value returned by resolveSession(). Defaults to nil (no stored session).
    var sessionToResolve: AuthSession?
    var isExpired = false
    var daysRemaining: Int?

    /// Tracks whether expireAnonymousSession() was called.
    var didCallExpire = false

    /// Tracks whether deleteAuthAccount() was called.
    var didCallDeleteAuthAccount = false

    /// Tracks whether signOut() was called.
    var didCallSignOut = false

    /// Set this to force any throwing method to throw a specific error.
    var errorToThrow: Error?

    func resolveSession() async -> AuthSession? {
        sessionToResolve
    }

    func signInWithEmail(email: String, password: String) async throws -> AuthSession {
        if let error = errorToThrow { throw error }
        return sessionToReturn
    }

    func createProfile(
        email: String,
        password: String,
        firstName: String,
        lastName: String
    ) async throws -> AuthSession {
        if let error = errorToThrow { throw error }
        return sessionToReturn
    }

    func signInAnonymously() async throws -> AuthSession {
        if let error = errorToThrow { throw error }
        return sessionToReturn
    }

    func signOut() async throws {
        if let error = errorToThrow { throw error }
        didCallSignOut = true
    }

    func deleteAuthAccount() async throws {
        if let error = errorToThrow { throw error }
        didCallDeleteAuthAccount = true
    }

    func linkAnonymousAccount(
        toEmail email: String,
        password: String,
        firstName: String,
        lastName: String
    ) async throws -> AuthSession {
        if let error = errorToThrow { throw error }
        return sessionToReturn
    }

    func resetPassword(email: String) async throws {
        if let error = errorToThrow { throw error }
    }

    func isAnonymousSessionExpired() -> Bool {
        isExpired
    }

    func anonymousDaysRemaining() -> Int? {
        daysRemaining
    }

    func expireAnonymousSession() async {
        didCallExpire = true
    }
}
