//
//  ProfileViewModel.swift
//  CatLedger
//
//  Created by Julien Cotte on 25/08/2026.
//

import Foundation
import CustomTextFields

/// Drives the profile editing form (first and last name).
/// Reports outcomes through `feedback` — it never talks to Toasty or builds UI text itself.
@Observable
@MainActor
final class ProfileViewModel {

    // MARK: Form Fields
    var firstName: String
    var lastName: String

    // MARK: Validation States
    var firstNameState: ValidationState = .neutral
    var lastNameState: ValidationState = .neutral

    // MARK: UI State
    var isLoading = false
    private(set) var feedback: ProfileFeedback?

    // MARK: Dependencies
    private let profile: Profile
    private let updateProfile: UpdateProfile

    /// - Parameters:
    ///   - profile: The profile being edited, pre-filling the form.
    ///   - updateProfile: Use case for persisting the edited name.
    init(profile: Profile, updateProfile: UpdateProfile) {
        self.profile = profile
        self.updateProfile = updateProfile
        firstName = profile.firstName
        lastName = profile.lastName
    }

    /// A name is valid when it is not empty (ignoring whitespace).
    /// Shared by the text fields (display) and the form validity checks so both stay in sync.
    func isValidName(_ value: String) -> Bool {
        !value.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Returns true when all required fields are filled and valid.
    var isFormValid: Bool {
        isValidName(firstName) && isValidName(lastName)
    }

    /// Validates and submits the form, persisting the edited name.
    func submit() async {
        guard validateForm() else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let input = UpdateProfileInput(
                id: profile.id,
                registrationId: profile.registrationId,
                firstName: firstName,
                lastName: lastName,
                photoURL: profile.photoURL
            )
            try await updateProfile.execute(input)
            feedback = .profileUpdated
        } catch let error as ProfileError {
            feedback = .error(error)
        } catch {
            feedback = .error(.updateFailed)
        }
    }

    // MARK: Private

    /// Forces validation on all required fields and returns whether the form is valid.
    private func validateForm() -> Bool {
        var isValid = true

        if !isValidName(firstName) {
            firstNameState = .invalid
            isValid = false
        }
        if !isValidName(lastName) {
            lastNameState = .invalid
            isValid = false
        }
        return isValid
    }
}
