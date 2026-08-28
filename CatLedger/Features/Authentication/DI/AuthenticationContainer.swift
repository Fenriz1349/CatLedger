//
//  AuthenticationContainer.swift
//  CatLedger
//
//  Created by Julien Cotte on 25/08/2026.
//

import Foundation

/// Composition root for the Authentication feature: builds the concrete `AuthenticationProviding`
/// implementation once, then wires every Authentication use case on top of it.
/// Holds no business logic itself — Presentation code reads its properties to get
/// use cases already wired and ready to inject into view models.
final class AuthenticationContainer {

    let provider: AuthenticationProviding

    let resolveSession: ResolveSession
    let logInWithEmail: LogInWithEmail
    let signUp: SignUp
    let logInAnonymously: LogInAnonymously
    let signOut: SignOut
    let deleteRegistration: DeleteRegistration
    let linkAnonymousRegistration: LinkAnonymousRegistration
    let resetPassword: ResetPassword

    /// - Parameter provider: The Authentication provider to wire every use case to.
    /// Defaults to the Firebase-backed implementation; override with a double in tests.
    init(provider: AuthenticationProviding = AuthenticationProvider()) {
        self.provider = provider
        resolveSession = ResolveSession(repository: provider)
        logInWithEmail = LogInWithEmail(repository: provider)
        signUp = SignUp(repository: provider)
        logInAnonymously = LogInAnonymously(repository: provider)
        signOut = SignOut(repository: provider)
        deleteRegistration = DeleteRegistration(repository: provider)
        linkAnonymousRegistration = LinkAnonymousRegistration(repository: provider)
        resetPassword = ResetPassword(repository: provider)
    }

    /// - Returns: A configured AuthenticationViewModel, wired with every use case it needs.
    func makeViewModel() -> AuthenticationViewModel {
        AuthenticationViewModel(logInWithEmail: logInWithEmail, signUp: signUp, resetPassword: resetPassword)
    }
}
