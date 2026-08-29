//
//  ProfileFormContent.swift
//  CatLedger
//
//  Created by Julien Cotte on 26/08/2026.
//

import SwiftUI
import CustomTextFields

/// Reusable form fields for editing a profile's name.
/// Purely presentational — contains no business logic.
struct ProfileFormContent: View {

    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var firstNameState: ValidationState
    @Binding var lastNameState: ValidationState
    /// Name validity rule, provided by the owning ViewModel (keeps the rule out of the view).
    let firstNameValidator: (String) -> Bool
    let lastNameValidator: (String) -> Bool

    var body: some View {
        VStack(spacing: 16) {
            CustomTextField(
                placeholder: String(localized: .profileFormFirstNamePlaceholder),
                text: $firstName,
                type: .lettersOnly,
                validator: firstNameValidator,
                errorMessage: String(localized: .profileFormFirstNameRequired),
                validationState: $firstNameState,
                showErrorOnlyWhenTriggered: false
            )
            .accessibilityIdentifier("profileField.firstName")
            CustomTextField(
                placeholder: String(localized: .profileFormLastNamePlaceholder),
                text: $lastName,
                type: .lettersOnly,
                validator: lastNameValidator,
                errorMessage: String(localized: .profileFormLastNameRequired),
                validationState: $lastNameState,
                showErrorOnlyWhenTriggered: false
            )
            .accessibilityIdentifier("profileField.lastName")
        }
    }
}
