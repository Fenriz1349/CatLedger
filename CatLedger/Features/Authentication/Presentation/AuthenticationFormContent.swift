//
//  AuthenticationFormContent.swift
//  CatLedger
//
//  Created by Julien Cotte on 25/08/2026.
//

import SwiftUI
import CustomTextFields

/// Reusable form fields for logging in and signing up.
/// Purely presentational — contains no business logic.
struct AuthenticationFormContent: View {

    @Binding var isSigningUp: Bool
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var emailState: ValidationState
    @Binding var passwordState: ValidationState
    @Binding var confirmPasswordState: ValidationState
    /// Confirmation rule (matches the password), provided by the owning ViewModel.
    let confirmPasswordValidator: (String) -> Bool

    var body: some View {
        VStack(spacing: 16) {
            CustomTextField(
                placeholder: String(localized: .authenticationFormEmailPlaceholder),
                text: $email,
                type: .email,
                errorMessage: String(localized: .authenticationFormEmailInvalid),
                validationState: $emailState,
                showErrorOnlyWhenTriggered: false
            )
            .accessibilityIdentifier("authenticationField.email")
            CustomTextField(
                placeholder: String(localized: .authenticationFormPasswordPlaceholder),
                text: $password,
                type: .password,
                errorMessage: AuthenticationError.weakPassword.errorDescription,
                validationState: $passwordState,
                showErrorOnlyWhenTriggered: false
            )
            .accessibilityIdentifier("authenticationField.password")
            if isSigningUp {
                CustomTextField(
                    placeholder: String(localized: .authenticationFormConfirmPasswordPlaceholder),
                    text: $confirmPassword,
                    type: .password,
                    validator: confirmPasswordValidator,
                    errorMessage: AuthenticationError.passwordsDoNotMatch.errorDescription,
                    validationState: $confirmPasswordState,
                    showErrorOnlyWhenTriggered: false
                )
                .accessibilityIdentifier("authenticationField.confirmPassword")
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSigningUp)
    }
}
