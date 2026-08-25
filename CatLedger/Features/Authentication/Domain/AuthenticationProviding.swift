//
//  AuthenticationProviding.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Defines the contract for all authentication operations.
/// The Domain layer depends only on this protocol — it has no knowledge of Firebase.
/// Conforming types live in the Data layer.
protocol AuthenticationProviding {

    /// Resolves an existing session from local storage without creating a new one.
    /// - Returns: The stored session, or nil if none exists (absence, not an error).
    func resolveSession() async -> AuthenticationSession?

    /// Signs in with an existing email and password.
    /// - Parameters:
    ///   - email: The email address to sign in with.
    ///   - password: The password to sign in with.
    /// - Returns: A session for the authenticated registration.
    func signInWithEmail(email: String, password: String) async throws -> AuthenticationSession

    /// Creates a new permanent registration with email and password.
    /// - Parameters:
    ///   - email: The registration's email address.
    ///   - password: The registration's password.
    /// - Returns: A session for the newly created registration.
    func signUp(email: String, password: String) async throws -> AuthenticationSession

    /// Signs in anonymously, creating a demo session without a permanent registration.
    /// - Returns: An anonymous session.
    func signInAnonymously() async throws -> AuthenticationSession

    /// Signs out the current registration and clears the local session.
    func signOut() async throws

    /// Permanently deletes the current registration.
    func deleteRegistration() async throws

    /// Links the current anonymous registration to a permanent email/password registration.
    /// - Parameters:
    ///   - email: The email address for the new permanent registration.
    ///   - password: The password for the new permanent registration.
    /// - Returns: An updated, non-anonymous session.
    func linkAnonymousRegistration(toEmail email: String, password: String) async throws -> AuthenticationSession

    /// Sends a password reset email to the given address.
    /// - Parameter email: The email address of the registration to reset.
    func resetPassword(email: String) async throws

    /// Returns whether the current anonymous session has exceeded its validity period.
    func isAnonymousSessionExpired() -> Bool

    /// Returns the number of days remaining in the anonymous demo session, or nil if not anonymous.
    func anonymousDaysRemaining() -> Int?

    /// Deletes the Firebase anonymous registration, then clears local session state.
    func expireAnonymousSession() async
}
