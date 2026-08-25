//
//  AuthProvider.swift
//  CatLedger
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation
import CryptoKit
import FirebaseAuth

/// Concrete implementation of `AuthProviding` backed by Firebase, via `FirebaseAuthSource`.
final class AuthProvider: AuthProviding {

    private static let anonymousSessionValidityDays = 7

    private let source: FirebaseAuthSource

    /// - Parameter source: The Firebase Auth wrapper used to perform the underlying calls.
    init(source: FirebaseAuthSource = FirebaseAuthSource()) {
        self.source = source
    }

    /// Resolves the session from Firebase Auth's own locally persisted current user.
    /// - Returns: The stored session, or nil if none exists.
    func resolveSession() async -> AuthSession? {
        guard let user = source.currentUser else { return nil }
        return session(for: user)
    }

    /// Signs in with an existing email and password.
    /// - Returns: A session for the authenticated registration.
    /// - Throws: `AuthError.invalidCredentials` for a wrong email/password, `AuthError.signInFailed` otherwise.
    func signInWithEmail(email: String, password: String) async throws -> AuthSession {
        do {
            return session(for: try await source.signIn(email: email, password: password))
        } catch {
            throw mapError(error, fallback: .signInFailed)
        }
    }

    /// Creates a new permanent registration with email and password.
    /// - Returns: A session for the newly created registration.
    /// - Throws: `AuthError.emailAlreadyInUse`/`weakPassword` when relevant, `AuthError.signInFailed` otherwise.
    func signUp(email: String, password: String) async throws -> AuthSession {
        do {
            return session(for: try await source.createUser(email: email, password: password))
        } catch {
            throw mapError(error, fallback: .signInFailed)
        }
    }

    /// Signs in anonymously, creating a demo session without a permanent registration.
    /// - Returns: An anonymous session.
    /// - Throws: `AuthError.signInFailed` if the anonymous sign-in fails.
    func signInAnonymously() async throws -> AuthSession {
        do {
            return session(for: try await source.signInAnonymously())
        } catch {
            throw mapError(error, fallback: .signInFailed)
        }
    }

    /// Signs out the current registration and clears the local session.
    /// - Throws: `AuthError.signOutFailed` if the sign-out fails.
    func signOut() async throws {
        do {
            try source.signOut()
        } catch {
            throw mapError(error, fallback: .signOutFailed)
        }
    }

    /// Permanently deletes the current registration.
    /// - Throws: `AuthError.deletionFailed` if the deletion fails.
    func deleteRegistration() async throws {
        do {
            try await source.deleteCurrentUser()
        } catch {
            throw mapError(error, fallback: .deletionFailed)
        }
    }

    /// Links the current anonymous registration to a permanent email/password registration.
    /// - Returns: An updated, non-anonymous session.
    /// - Throws: `AuthError.registrationLinkingFailed` if the link fails.
    func linkAnonymousRegistration(toEmail email: String, password: String) async throws -> AuthSession {
        do {
            return session(for: try await source.linkCurrentUser(toEmail: email, password: password))
        } catch {
            throw mapError(error, fallback: .registrationLinkingFailed)
        }
    }

    /// Sends a password reset email to the given address.
    /// - Throws: `AuthError.resetPasswordFailed` if the email fails to send.
    func resetPassword(email: String) async throws {
        do {
            try await source.sendPasswordReset(email: email)
        } catch {
            throw mapError(error, fallback: .resetPasswordFailed)
        }
    }

    /// Checks whether the current anonymous session has exceeded its validity period.
    /// - Returns: `true` if the session is anonymous and older than the validity period.
    func isAnonymousSessionExpired() -> Bool {
        (anonymousDaysRemaining() ?? 1) <= 0
    }

    /// Computes the number of days remaining before an anonymous session expires.
    /// - Returns: The number of days remaining, or nil if the session isn't anonymous.
    func anonymousDaysRemaining() -> Int? {
        guard
            let user = source.currentUser, user.isAnonymous,
            let creationDate = user.metadata.creationDate
        else { return nil }
        let elapsedDays = Calendar.current.dateComponents([.day], from: creationDate, to: Date()).day ?? 0
        return max(0, Self.anonymousSessionValidityDays - elapsedDays)
    }

    /// Deletes the Firebase anonymous registration, then clears local session state.
    func expireAnonymousSession() async {
        try? await source.deleteCurrentUser()
    }

    // MARK: Private

    /// Builds an AuthSession for the given Firebase user, deriving a stable registration
    /// identifier from its uid.
    private func session(for user: FirebaseAuth.User) -> AuthSession {
        AuthSession(registrationId: registrationId(for: user.uid), isAnonymous: user.isAnonymous)
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

    /// Maps a Firebase error to a domain `AuthError`, falling back to a context-appropriate default.
    private func mapError(_ error: Error, fallback: AuthError) -> AuthError {
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
