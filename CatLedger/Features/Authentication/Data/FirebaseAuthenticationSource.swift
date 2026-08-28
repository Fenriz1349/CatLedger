//
//  FirebaseAuthenticationSource.swift
//  CatLedger
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation
import FirebaseAuth

/// Thin wrapper around the Firebase Auth SDK. Holds no business logic, only raw SDK calls —
/// error mapping and identifier derivation are the responsibility of the caller.
final class FirebaseAuthenticationSource {

    /// Thrown when an operation requires a signed-in user but none is currently set.
    struct NoCurrentUser: Error {}

    private var auth: Auth { Auth.auth() }

    /// The currently signed-in Firebase user, if any.
    var currentUser: FirebaseAuth.User? { auth.currentUser }

    /// Logs in with an existing email and password.
    /// - Returns: The logged-in Firebase user.
    func login(email: String, password: String) async throws -> FirebaseAuth.User {
        try await auth.signIn(withEmail: email, password: password).user
    }

    /// Creates a new permanent account with email and password.
    /// - Returns: The newly created Firebase user.
    func createUser(email: String, password: String) async throws -> FirebaseAuth.User {
        try await auth.createUser(withEmail: email, password: password).user
    }

    /// Logs in anonymously, creating a new anonymous account.
    /// - Returns: The newly created anonymous Firebase user.
    func loginAnonymously() async throws -> FirebaseAuth.User {
        try await auth.signInAnonymously().user
    }

    /// Signs out the current user.
    func signOut() throws {
        try auth.signOut()
    }

    /// Permanently deletes the current user's account.
    /// - Throws: `NoCurrentUser` if no user is signed in.
    func deleteCurrentUser() async throws {
        guard let user = auth.currentUser else { throw NoCurrentUser() }
        try await user.delete()
    }

    /// Links the current anonymous user to a permanent email/password credential.
    /// - Returns: The updated, non-anonymous Firebase user.
    /// - Throws: `NoCurrentUser` if no user is signed in.
    func linkCurrentUser(toEmail email: String, password: String) async throws -> FirebaseAuth.User {
        guard let user = auth.currentUser else { throw NoCurrentUser() }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        return try await user.link(with: credential).user
    }

    /// Sends a password reset email to the given address.
    func sendPasswordReset(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }
}
