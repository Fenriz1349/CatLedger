//
//  AuthenticationFormContent.swift
//  CatLedger
//
//  Created by Julien Cotte on 25/08/2026.
//

import SwiftUI
import CustomTextFields

/// Reusable form fields for authentication and account linking.
/// Purely presentational — contains no business logic.
struct AuthenticationFormContent: View {

    @Binding var isSignUp: Bool
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var firstNameState: ValidationState
    @Binding var lastNameState: ValidationState
    @Binding var emailState: ValidationState
    @Binding var passwordState: ValidationState
    @Binding var confirmPasswordState: ValidationState
    /// Name validity rule, provided by the owning ViewModel (keeps the rule out of the view).
    let firstNameValidator: (String) -> Bool
    let lastNameValidator: (String) -> Bool
    /// Confirmation rule (matches the password), provided by the owning ViewModel.
    let confirmPasswordValidator: (String) -> Bool

    var body: some View {
        VStack(spacing: 16) {
            if isSignUp {
                CustomTextField(
                    placeholder: "Prénom",
                    text: $firstName,
                    type: .lettersOnly,
                    validator: firstNameValidator,
                    errorMessage: "Le prénom est requis.",
                    validationState: $firstNameState,
                    showErrorOnlyWhenTriggered: false
                )
                .accessibilityIdentifier("authenticationField.firstName")
                CustomTextField(
                    placeholder: "Nom",
                    text: $lastName,
                    type: .lettersOnly,
                    validator: lastNameValidator,
                    errorMessage: "Le nom est requis.",
                    validationState: $lastNameState,
                    showErrorOnlyWhenTriggered: false
                )
                .accessibilityIdentifier("authenticationField.lastName")
            }
            CustomTextField(
                placeholder: "Email",
                text: $email,
                type: .email,
                errorMessage: "Adresse email invalide.",
                validationState: $emailState,
                showErrorOnlyWhenTriggered: false
            )
            .accessibilityIdentifier("authenticationField.email")
            CustomTextField(
                placeholder: "Mot de passe",
                text: $password,
                type: .password,
                errorMessage: AuthenticationError.weakPassword.errorDescription,
                validationState: $passwordState,
                showErrorOnlyWhenTriggered: false
            )
            .accessibilityIdentifier("authenticationField.password")
            if isSignUp {
                CustomTextField(
                    placeholder: "Confirmer le mot de passe",
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
        .animation(.easeInOut(duration: 0.2), value: isSignUp)
    }
}
