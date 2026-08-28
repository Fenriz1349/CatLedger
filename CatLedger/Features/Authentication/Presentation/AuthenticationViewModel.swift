//
//  AuthenticationViewModel.swift
//  CatLedger
//
//  Created by Julien Cotte on 25/08/2026.
//

import Foundation
import CustomTextFields

/// Drives the log-in form, password reset, sign-up, and anonymous sign-up. Purely Authentication —
/// knows nothing about Profile. Its role is limited to calling its own use cases and reporting
/// whether they succeeded or failed; it never decides what else should happen as a result.
@Observable
@MainActor
final class AuthenticationViewModel {

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
    private let logInWithEmail: LogInWithEmail
    private let signUpUseCase: SignUp
    private let signUpAnonymouslyUseCase: SignUpAnonymously
    private let forgottenPasswordUseCase: ForgottenPassword

    /// - Parameters:
    ///   - logInWithEmail: Use case for logging in with email and password.
    ///   - signUp: Use case for creating a new registration.
    ///   - signUpAnonymously: Use case for creating a new anonymous registration.
    ///   - forgottenPassword: Use case for sending a password reset email.
    init(
        logInWithEmail: LogInWithEmail,
        signUp: SignUp,
        signUpAnonymously: SignUpAnonymously,
        forgottenPassword: ForgottenPassword
    ) {
        self.logInWithEmail = logInWithEmail
        self.signUpUseCase = signUp
        self.signUpAnonymouslyUseCase = signUpAnonymously
        self.forgottenPasswordUseCase = forgottenPassword
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
    func logIn() async {
        guard validateForm() else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await logInWithEmail.execute(email: email, password: password)
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

