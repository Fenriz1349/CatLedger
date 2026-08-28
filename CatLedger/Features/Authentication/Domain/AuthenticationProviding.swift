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

    /// Logs in with an existing email and password.
    /// - Parameters:
    ///   - email: The email address to log in with.
    ///   - password: The password to log in with.
    /// - Returns: A session for the authenticated registration.
    func login(withEmail email: String, password: String) async throws -> AuthenticationSession

    /// Creates a new permanent registration with email and password.
    /// - Parameters:
    ///   - email: The registration's email address.
    ///   - password: The registration's password.
    /// - Returns: A session for the newly created registration.
    func signUp(email: String, password: String) async throws -> AuthenticationSession

    /// Creates a new anonymous registration to start a demo session.
    /// - Returns: An anonymous session.
    func signUpAnonymously() async throws -> AuthenticationSession

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
    func forgottenPassword(email: String) async throws
}
