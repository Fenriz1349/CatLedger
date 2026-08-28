//
//  AuthenticationViewModel.swift
//  CatLedger
//
//  Created by Julien Cotte on 25/08/2026.
//

import Foundation
import CustomTextFields

/// Drives every purely-Authentication action, for both a not-yet-authenticated session
/// (log-in form, password reset, sign-up, anonymous sign-up) and an already-authenticated one
/// (log-out). Knows nothing about Profile. Its role is limited to calling its own use cases and
/// reporting whether they succeeded or failed; it never decides what else should happen as a result.
@Observable
@MainActor
final class AuthenticationViewModel {

    /// Whether this view model drives the not-yet-authenticated form, or an already-authenticated
    /// session's actions.
    enum Context: Equatable {
        case unauthenticated
        case authenticated
    }

    // MARK: Form Fields
    var email = ""
    var password = ""
    var confirmPassword = ""

    // MARK: Validation States
    var emailState: ValidationState = .neutral
    var passwordState: ValidationState = .neutral
    var confirmPasswordState: ValidationState = .neutral

    // MARK: UI State
    var isSigningUp = false
    var isLoading = false
    private(set) var feedback: AuthenticationFeedback?

    // MARK: Dependencies
    private let context: Context
    private let logInWithEmail: LogInWithEmail
    private let signUpUseCase: SignUp
    private let signUpAnonymouslyUseCase: SignUpAnonymously
    private let forgottenPasswordUseCase: ForgottenPassword
    private let logOutUseCase: LogOut
    private let onAuthenticated: (AuthenticationSession) async -> Void
    private let onLoggedOut: () async -> Void

    /// - Parameters:
    ///   - context: Whether this view model drives the not-yet-authenticated form or an
    ///   already-authenticated session's actions.
    ///   - logInWithEmail: Use case for logging in with email and password.
    ///   - signUp: Use case for creating a new registration.
    ///   - signUpAnonymously: Use case for creating a new anonymous registration.
    ///   - forgottenPassword: Use case for sending a password reset email.
    ///   - logOut: Use case for logging out of the current registration.
    ///   - onAuthenticated: Called after a successful log-in, with the resulting session.
    ///   - onLoggedOut: Called after a successful log-out.
    init(
        context: Context,
        logInWithEmail: LogInWithEmail,
        signUp: SignUp,
        signUpAnonymously: SignUpAnonymously,
        forgottenPassword: ForgottenPassword,
        logOut: LogOut,
        onAuthenticated: @escaping (AuthenticationSession) async -> Void,
        onLoggedOut: @escaping () async -> Void
    ) {
        self.context = context
        self.logInWithEmail = logInWithEmail
        self.signUpUseCase = signUp
        self.signUpAnonymouslyUseCase = signUpAnonymously
        self.forgottenPasswordUseCase = forgottenPassword
        self.logOutUseCase = logOut
        self.onAuthenticated = onAuthenticated
        self.onLoggedOut = onLoggedOut
    }

    /// The confirmation is valid when it is not empty and matches the password.
    /// Lets the confirm field show the mismatch live, instead of only via the disabled button.
    func isValidConfirmPassword(_ value: String) -> Bool {
        !value.isEmpty && value == password
    }

    /// Returns true when all required fields are filled and valid.
    var isFormValid: Bool {
        let base = Validators.isValidEmail(email) && Validators.isStrongPassword(password)
        guard isSigningUp else { return base }
        return base && password == confirmPassword
    }

    /// Validates and logs in with the current email and password.
    /// Calls `onAuthenticated` with the resulting session on success.
    func logIn() async {
        guard validateForm() else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let session = try await logInWithEmail.execute(email: email, password: password)
            await onAuthenticated(session)
        } catch let error as AuthenticationError {
            feedback = .error(error)
        } catch {
            feedback = .error(.logInFailed)
        }
    }

    /// Creates a new Firebase registration from the current email and password.
    /// - Returns: A session for the newly created registration.
    func signUp() async throws -> AuthenticationSession {
        try await signUpUseCase.execute(email: email, password: password)
    }

    /// Creates a new anonymous Firebase registration.
    /// - Returns: An anonymous session.
    func signUpAnonymously() async throws -> AuthenticationSession {
        try await signUpAnonymouslyUseCase.execute()
    }

    /// Logs out of the current registration. Calls `onLoggedOut` on success.
    func logOut() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await logOutUseCase.execute()
            await onLoggedOut()
        } catch let error as AuthenticationError {
            feedback = .error(error)
        } catch {
            feedback = .error(.logOutFailed)
        }
    }

    /// Sends a password reset email using the current email field value.
    func forgottenPassword() async {
        guard Validators.isValidEmail(email) else {
            emailState = .invalid
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            try await forgottenPasswordUseCase.execute(email: email)
            feedback = .passwordResetSent
        } catch let error as AuthenticationError {
            feedback = .error(error)
        } catch {
            feedback = .error(.forgottenPasswordFailed)
        }
    }

    // MARK: Private

    /// Forces validation on all required fields and returns whether the form is valid.
    private func validateForm() -> Bool {
        var isValid = true

        if !Validators.isValidEmail(email) {
            emailState = .invalid
            isValid = false
        }
        if !Validators.isStrongPassword(password) {
            passwordState = .invalid
            isValid = false
        }
        if isSigningUp, password != confirmPassword {
            confirmPasswordState = .invalid
            isValid = false
        }
        return isValid
    }
}
