//
//  AuthenticationProvider.swift
//  CatLedger
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation
import CryptoKit
import FirebaseAuth

/// Concrete implementation of `AuthenticationProviding` backed by Firebase, via `FirebaseAuthenticationSource`.
final class AuthenticationProvider: AuthenticationProviding {

    private let source: FirebaseAuthenticationSource

    /// - Parameter source: The Firebase Auth wrapper used to perform the underlying calls.
    init(source: FirebaseAuthenticationSource = FirebaseAuthenticationSource()) {
        self.source = source
    }

    /// Resolves the session from Firebase Auth's own locally persisted current user.
    /// - Returns: The stored session, or nil if none exists.
    func resolveSession() async -> AuthenticationSession? {
        guard let user = source.currentUser else { return nil }
        return session(for: user)
    }

    /// Logs in with an existing email and password.
    /// - Returns: A session for the authenticated registration.
    /// - Throws: `AuthenticationError.invalidCredentials` for a wrong email/password,
    /// `AuthenticationError.logInFailed` otherwise.
    func login(withEmail email: String, password: String) async throws -> AuthenticationSession {
        do {
            return session(for: try await source.login(email: email, password: password))
        } catch {
            throw mapError(error, fallback: .logInFailed)
        }
    }

    /// Creates a new permanent registration with email and password.
    /// - Returns: A session for the newly created registration.
    /// - Throws: `AuthenticationError.emailAlreadyInUse`/`weakPassword` when relevant,
    /// `AuthenticationError.logInFailed` otherwise.
    func signUp(email: String, password: String) async throws -> AuthenticationSession {
        do {
            return session(for: try await source.createUser(email: email, password: password))
        } catch {
            throw mapError(error, fallback: .logInFailed)
        }
    }

    /// Logs in anonymously, creating a demo session without a permanent registration.
    /// - Returns: An anonymous session.
    /// - Throws: `AuthenticationError.logInFailed` if the anonymous login fails.
    func logInAnonymously() async throws -> AuthenticationSession {
        do {
            return session(for: try await source.loginAnonymously())
        } catch {
            throw mapError(error, fallback: .logInFailed)
        }
    }

    /// Signs out the current registration and clears the local session.
    /// - Throws: `AuthenticationError.signOutFailed` if the sign-out fails.
    func signOut() async throws {
        do {
            try source.signOut()
        } catch {
            throw mapError(error, fallback: .signOutFailed)
        }
    }

    /// Permanently deletes the current registration.
    /// - Throws: `AuthenticationError.deletionFailed` if the deletion fails.
    func deleteRegistration() async throws {
        do {
            try await source.deleteCurrentUser()
        } catch {
            throw mapError(error, fallback: .deletionFailed)
        }
    }

    /// Links the current anonymous registration to a permanent email/password registration.
    /// - Returns: An updated, non-anonymous session.
    /// - Throws: `AuthenticationError.registrationLinkingFailed` if the link fails.
    func linkAnonymousRegistration(toEmail email: String, password: String) async throws -> AuthenticationSession {
        do {
            return session(for: try await source.linkCurrentUser(toEmail: email, password: password))
        } catch {
            throw mapError(error, fallback: .registrationLinkingFailed)
        }
    }

    /// Sends a password reset email to the given address.
    /// - Throws: `AuthenticationError.resetPasswordFailed` if the email fails to send.
    func resetPassword(email: String) async throws {
        do {
            try await source.sendPasswordReset(email: email)
        } catch {
            throw mapError(error, fallback: .resetPasswordFailed)
        }
    }

    // MARK: Private

    /// Builds an AuthenticationSession for the given Firebase user, deriving a stable registration
    /// identifier from its uid.
    private func session(for user: FirebaseAuth.User) -> AuthenticationSession {
        AuthenticationSession(registrationId: registrationId(for: user.uid), email: user.email)
    }

    /// Derives a deterministic UUID from a Firebase uid, so the same registration always
    /// resolves to the same identifier without persisting a separate mapping.
    private func registrationId(for firebaseUID: String) -> UUID {
        let digest = SHA256.hash(data: Data(firebaseUID.utf8))
        let bytes = Array(digest.prefix(16))
        return bytes.withUnsafeBufferPointer { buffer in
            NSUUID(uuidBytes: buffer.baseAddress!) as UUID
        }
    }

    /// Maps a Firebase error to a domain `AuthenticationError`, falling back to a context-appropriate default.
    private func mapError(_ error: Error, fallback: AuthenticationError) -> AuthenticationError {
        guard let code = AuthErrorCode(rawValue: (error as NSError).code) else { return fallback }
        switch code {
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .wrongPassword, .userNotFound, .invalidEmail:
            return .invalidCredentials
        default:
            return fallback
        }
    }
}
