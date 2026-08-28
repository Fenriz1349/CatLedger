//
//  AuthenticationProfileViewModel.swift
//  CatLedger
//
//  Created by Julien Cotte on 27/08/2026.
//

import Foundation
import CustomTextFields

/// Drives the actions that need both Authentication and Profile together: signing up with a
/// profile, and continuing as a demo. Holds only the cross-feature use cases it needs — it never
/// reaches into `AuthenticationViewModel` or `ProfileViewModel`, and it never decides what the
/// app does after a use case succeeds; it only reports whether it failed.
///
/// Owns `firstName`/`lastName` itself, rather than going through `ProfileViewModel`: at sign-up
/// time no registration exists yet, so there is no `registrationId` to build a `ProfileViewModel`
/// with. These fields exist only to feed `signUp(email:password:)`.
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
    private let onAuthenticated: (AuthenticationSession) async -> Void

    /// - Parameters:
    ///   - registerProfile: Use case for creating a permanent registration and its profile together.
    ///   - registerAnonymousProfile: Use case for creating an anonymous registration and its
    ///   placeholder profile together.
    ///   - onAuthenticated: Called after a successful sign-up or demo entry, with the resulting session.
    init(
        registerProfile: RegisterProfile,
        registerAnonymousProfile: RegisterAnonymousProfile,
        onAuthenticated: @escaping (AuthenticationSession) async -> Void
    ) {
        self.registerProfile = registerProfile
        self.registerAnonymousProfile = registerAnonymousProfile
        self.onAuthenticated = onAuthenticated
    }

    /// A name is valid when it is not empty (ignoring whitespace).
    /// Shared by the text fields (display) and the form validity checks so both stay in sync.
    func isValidName(_ value: String) -> Bool {
        !value.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Returns true when `firstName` and `lastName` are both filled and valid.
    var isProfileFormValid: Bool {
        isValidName(firstName) && isValidName(lastName)
    }

    /// Creates a new permanent registration and its profile, from the current `firstName`/`lastName`.
    /// Calls `onAuthenticated` with the resulting session on success.
    /// - Parameters:
    ///   - email: The registration's email address.
    ///   - password: The registration's password.
    func signUp(email: String, password: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let session = try await registerProfile.execute(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password
            )
            await onAuthenticated(session)
        } catch let error as AuthenticationError {
            feedback = .authenticationError(error)
        } catch let error as ProfileError {
            feedback = .profileError(error)
        } catch {
            feedback = .authenticationError(.logInFailed)
        }
    }

    /// Creates a new anonymous registration and its placeholder profile.
    /// Calls `onAuthenticated` with the resulting session on success.
    func continueAsDemo() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let session = try await registerAnonymousProfile.execute()
            await onAuthenticated(session)
        } catch let error as AuthenticationError {
            feedback = .authenticationError(error)
        } catch let error as ProfileError {
            feedback = .profileError(error)
        } catch {
            feedback = .authenticationError(.logInFailed)
        }
    }
}
