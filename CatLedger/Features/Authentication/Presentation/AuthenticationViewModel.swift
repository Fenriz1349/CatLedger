//
//  AuthenticationViewModel.swift
//  CatLedger
//
//  Created by Julien Cotte on 25/08/2026.
//

import Foundation
import CustomTextFields

/// Drives the sign-in / sign-up form and the anonymous demo entry point.
/// Reports outcomes through `feedback` — it never talks to Toasty or builds UI text itself.
@Observable
@MainActor
final class AuthenticationViewModel {

    // MARK: Form Fields
    var firstName = ""
    var lastName = ""
    var email = ""
    var password = ""
    var confirmPassword = ""

    // MARK: Validation States
    var firstNameState: ValidationState = .neutral
    var lastNameState: ValidationState = .neutral
    var emailState: ValidationState = .neutral
    var passwordState: ValidationState = .neutral
    var confirmPasswordState: ValidationState = .neutral

    // MARK: UI State
    var isSignUp = false
    var isLoading = false
    private(set) var feedback: AuthenticationFeedback?

    // MARK: Dependencies
    private let signUp: SignUp
    private let signInWithEmail: SignInWithEmail
    private let signInAnonymously: SignInAnonymously
    private let resetPassword: ResetPassword

    /// - Parameters:
    ///   - signUp: Use case for creating a new registration.
    ///   - signInWithEmail: Use case for email/password sign-in.
    ///   - signInAnonymously: Use case for starting an anonymous demo session.
    ///   - resetPassword: Use case for sending a password reset email.
    init(
        signUp: SignUp,
        signInWithEmail: SignInWithEmail,
        signInAnonymously: SignInAnonymously,
        resetPassword: ResetPassword
    ) {
        self.signUp = signUp
        self.signInWithEmail = signInWithEmail
        self.signInAnonymously = signInAnonymously
        self.resetPassword = resetPassword
    }

    /// A name is valid when it is not empty (ignoring whitespace).
    /// Shared by the text fields (display) and the form validity checks so both stay in sync.
    func isValidName(_ value: String) -> Bool {
        !value.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// The confirmation is valid when it is not empty and matches the password.
    /// Lets the confirm field show the mismatch live, instead of only via the disabled button.
    func isValidConfirmPassword(_ value: String) -> Bool {
        !value.isEmpty && value == password
    }

    /// Returns true when all required fields are filled and valid.
    var isFormValid: Bool {
        let base = Validators.isValidEmail(email) && Validators.isStrongPassword(password)
        guard isSignUp else { return base }
        return base
            && isValidName(firstName)
            && isValidName(lastName)
            && password == confirmPassword
    }

    /// Validates and submits the form, signing in or creating an account depending on the current mode.
    func submit() async {
        guard validateForm() else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            if isSignUp {
                _ = try await signUp.execute(email: email, password: password)
                feedback = .accountCreated
            } else {
                _ = try await signInWithEmail.execute(email: email, password: password)
                feedback = .signedIn
            }
        } catch let error as AuthenticationError {
            feedback = .error(error)
        } catch {
            feedback = .error(.signInFailed)
        }
    }

    /// Starts an anonymous demo session.
    func continueAnonymously() async {
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await signInAnonymously.execute()
            feedback = .continuedAsDemo
        } catch let error as AuthenticationError {
            feedback = .error(error)
        } catch {
            feedback = .error(.signInFailed)
        }
    }

    /// Sends a password reset email using the current email field value.
    func forgotPassword() async {
        guard Validators.isValidEmail(email) else {
            emailState = .invalid
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            try await resetPassword.execute(email: email)
            feedback = .passwordResetSent
        } catch let error as AuthenticationError {
            feedback = .error(error)
        } catch {
            feedback = .error(.resetPasswordFailed)
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
        if isSignUp {
            if !isValidName(firstName) {
                firstNameState = .invalid
                isValid = false
            }
            if !isValidName(lastName) {
                lastNameState = .invalid
                isValid = false
            }
            if password != confirmPassword {
                confirmPasswordState = .invalid
                isValid = false
            }
        }
        return isValid
    }
}
