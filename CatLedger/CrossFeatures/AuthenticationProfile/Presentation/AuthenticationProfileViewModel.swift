//
//  AuthenticationProfileViewModel.swift
//  CatLedger
//
//  Created by Julien Cotte on 27/08/2026.
//

import Foundation

/// Drives the actions that need both Authentication and Profile together: signing up with a
/// profile, and continuing as a demo. Holds only the cross-feature use cases it needs — it never
/// reaches into `AuthenticationViewModel` or `ProfileViewModel`, and it never decides what the
/// app does after a use case succeeds; it only reports whether it failed.
@Observable
@MainActor
final class AuthenticationProfileViewModel {

    var isLoading = false
    private(set) var feedback: AuthenticationProfileFeedback?

    private let registerProfile: RegisterProfile
    private let registerAnonymousProfile: RegisterAnonymousProfile

    /// - Parameters:
    ///   - registerProfile: Use case for creating a permanent registration and its profile together.
    ///   - registerAnonymousProfile: Use case for creating an anonymous registration and its
    ///   placeholder profile together.
    init(registerProfile: RegisterProfile, registerAnonymousProfile: RegisterAnonymousProfile) {
        self.registerProfile = registerProfile
        self.registerAnonymousProfile = registerAnonymousProfile
    }

    /// Creates a new permanent registration and its profile.
    /// - Parameters:
    ///   - firstName: The profile's first name.
    ///   - lastName: The profile's last name.
    ///   - email: The registration's email address.
    ///   - password: The registration's password.
    /// - Returns: The newly created session, or nil if the operation failed.
    func signUp(firstName: String, lastName: String, email: String, password: String) async -> AuthenticationSession? {
        isLoading = true
        defer { isLoading = false }
        do {
            return try await registerProfile.execute(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password
            )
        } catch let error as AuthenticationError {
            feedback = .authenticationError(error)
        } catch let error as ProfileError {
            feedback = .profileError(error)
        } catch {
            feedback = .authenticationError(.logInFailed)
        }
        return nil
    }

    /// Creates a new anonymous registration and its placeholder profile.
    /// - Returns: The newly created anonymous session, or nil if the operation failed.
    func continueAsDemo() async -> AuthenticationSession? {
        isLoading = true
        defer { isLoading = false }
        do {
            return try await registerAnonymousProfile.execute()
        } catch let error as AuthenticationError {
            feedback = .authenticationError(error)
        } catch let error as ProfileError {
            feedback = .profileError(error)
        } catch {
            feedback = .authenticationError(.logInFailed)
        }
        return nil
    }
}
