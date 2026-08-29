//
//  ProfileViewModel.swift
//  CatLedger
//
//  Created by Julien Cotte on 25/08/2026.
//

import Foundation
import CustomTextFields

/// Drives the profile form, for both creating a new profile and editing an existing one.
/// Reports outcomes through `feedback` — it never talks to Toasty or builds UI text itself.
@Observable
@MainActor
final class ProfileViewModel {

    /// Which profile this form acts on: a brand-new one for the given registration,
    /// or an already-existing one being edited.
    enum Context {
        case create(registrationId: UUID)
        case existing(Profile)
    }

    // MARK: Form Fields
    var firstName: String
    var lastName: String

    // MARK: Validation States
    var firstNameState: ValidationState = .neutral
    var lastNameState: ValidationState = .neutral

    // MARK: UI State
    /// Whether the edit form is shown instead of the plain name display. Only meaningful for
    /// `.existing` — `.create` is always shown as a form.
    var isEditing = false
    var isLoading = false
    private(set) var feedback: ProfileFeedback?

    // MARK: Dependencies
    private let context: Context
    private let createProfileUseCase: CreateProfile
    private let updateProfileUseCase: UpdateProfile

    /// - Parameters:
    ///   - context: Whether this form creates a new profile or edits an existing one.
    ///   - createProfile: Use case for persisting a newly created profile.
    ///   - updateProfile: Use case for persisting an edited profile.
    init(context: Context, createProfile: CreateProfile, updateProfile: UpdateProfile) {
        self.context = context
        self.createProfileUseCase = createProfile
        self.updateProfileUseCase = updateProfile
        switch context {
        case .create:
            firstName = ""
            lastName = ""
        case .existing(let profile):
            firstName = profile.firstName
            lastName = profile.lastName
        }
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

    /// Validates and submits the form, creating or persisting the name depending on `context`.
    func submit() async {
        guard validateForm() else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            switch context {
            case .create(let registrationId):
                _ = try await createProfileUseCase.execute(
                    registrationId: registrationId,
                    firstName: firstName,
                    lastName: lastName
                )
            case .existing(let profile):
                let input = UpdateProfileInput(
                    id: profile.id,
                    registrationId: profile.registrationId,
                    firstName: firstName,
                    lastName: lastName,
                    photoURL: profile.photoURL
                )
                try await updateProfileUseCase.execute(input)
                isEditing = false
            }
        } catch let error as ProfileError {
            feedback = .error(error)
        } catch {
            switch context {
            case .create:
                feedback = .error(.creationFailed)
            case .existing:
                feedback = .error(.updateFailed)
            }
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
