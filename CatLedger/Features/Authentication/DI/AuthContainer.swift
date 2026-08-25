//
//  AuthContainer.swift
//  CatLedger
//
//  Created by Julien Cotte on 25/08/2026.
//

import Foundation

/// Composition root for the Authentication feature: builds the concrete `AuthProviding`
/// implementation once, then wires every Authentication use case on top of it.
/// Holds no business logic itself — Presentation code reads its properties to get
/// use cases already wired and ready to inject into view models.
final class AuthContainer {

    let provider: AuthProviding

    let resolveSession: ResolveSession
    let signInWithEmail: SignInWithEmail
    let signUp: SignUp
    let signInAnonymously: SignInAnonymously
    let signOut: SignOut
    let deleteRegistration: DeleteRegistration
    let linkAnonymousRegistration: LinkAnonymousRegistration
    let resetPassword: ResetPassword
    let isAnonymousSessionExpired: IsAnonymousSessionExpired
    let expireAnonymousSession: ExpireAnonymousSession

    /// - Parameter provider: The Authentication provider to wire every use case to.
    /// Defaults to the Firebase-backed implementation; override with a double in tests.
    init(provider: AuthProviding = AuthProvider()) {
        self.provider = provider
        resolveSession = ResolveSession(repository: provider)
        signInWithEmail = SignInWithEmail(repository: provider)
        signUp = SignUp(repository: provider)
        signInAnonymously = SignInAnonymously(repository: provider)
        signOut = SignOut(repository: provider)
        deleteRegistration = DeleteRegistration(repository: provider)
        linkAnonymousRegistration = LinkAnonymousRegistration(repository: provider)
        resetPassword = ResetPassword(repository: provider)
        isAnonymousSessionExpired = IsAnonymousSessionExpired(repository: provider)
        expireAnonymousSession = ExpireAnonymousSession(repository: provider)
    }
}
