//
//  AuthenticationProfileViewModel.swift
//  CatLedger
//
//  Created by Julien Cotte on 27/08/2026.
//

import Foundation
import CustomTextFields

/// Drives the profile half of account creation (first and last name), and orchestrates the
/// cross-feature actions that create both a registration and its profile together.
/// Reports outcomes through `feedback` — it never talks to Toasty or builds UI text itself.
@Observable
@MainActor
final class AuthenticationProfileViewModel {

    // MARK: Form Fields
    var firstName = ""
    var lastName = ""

    // MARK: Validation States
    var firstNameState: ValidationState = .neutral
    var lastNameState: ValidationState = .neutral

    // MARK: UI State
    var isLoading = false
    private(set) var feedback: AuthenticationProfileFeedback?

    // MARK: Dependencies
    private let registerProfile: RegisterProfile
    private let registerAnonymousProfile: RegisterAnonymousProfile

    /// - Parameters:
    ///   - registerProfile: Use case for creating a registration and its profile together.
    ///   - registerAnonymousProfile: Use case for creating an anonymous registration and its placeholder profile.
    init(registerProfile: RegisterProfile, registerAnonymousProfile: RegisterAnonymousProfile) {
        self.registerProfile = registerProfile
        self.registerAnonymousProfile = registerAnonymousProfile
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

    /// Validates the name fields and creates a new registration and its profile together.
    /// - Parameters:
    ///   - email: The registration's email address.
    ///   - password: The registration's password.
    func createAccount(email: String, password: String) async {
        guard validateForm() else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await registerProfile.execute(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password
            )
            feedback = .accountCreated
        } catch let error as AuthenticationError {
            feedback = .authenticationError(error)
        } catch let error as ProfileError {
            feedback = .profileError(error)
        } catch {
            feedback = .authenticationError(.signInFailed)
        }
    }

    /// Creates an anonymous registration and its placeholder profile.
    func continueAsDemo() async {
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await registerAnonymousProfile.execute()
            feedback = .continuedAsDemo
        } catch let error as AuthenticationError {
            feedback = .authenticationError(error)
        } catch let error as ProfileError {
            feedback = .profileError(error)
        } catch {
            feedback = .authenticationError(.signInFailed)
        }
    }

    // MARK: Private

    /// Forces validation on the name fields and returns whether the form is valid.
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
