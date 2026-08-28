//
//  AuthenticationViewModelTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 26/08/2026.
//

import Foundation
import Testing
import CustomTextFields
@testable import CatLedger

@MainActor
struct AuthenticationViewModelTests {

    private struct GenericError: Error {}

    private let repository = AuthenticationDouble()
    private let viewModel: AuthenticationViewModel

    init() {
        viewModel = AuthenticationViewModel(
            logInWithEmail: LogInWithEmail(repository: repository),
            signUp: SignUp(repository: repository),
            signUpAnonymously: SignUpAnonymously(repository: repository),
            forgottenPassword: ForgottenPassword(repository: repository)
        )
    }

    // MARK: isFormValid

    @Test("Login mode is valid with just a valid email and a strong password")
    func isFormValid_login_validEmailAndPassword_returnsTrue() {
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        #expect(viewModel.isFormValid)
    }

    @Test("Signing-up mode is invalid when the confirmation doesn't match the password")
    func isFormValid_signingUp_mismatchedConfirmation_returnsFalse() {
        viewModel.isSigningUp = true
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        viewModel.confirmPassword = "Mismatch123!"
        #expect(!viewModel.isFormValid)
    }

    @Test("Signing-up mode is valid once every field matches")
    func isFormValid_signingUp_allFieldsValid_returnsTrue() {
        viewModel.isSigningUp = true
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        viewModel.confirmPassword = TestData.password
        #expect(viewModel.isFormValid)
    }

    // MARK: logIn

    @Test("Logging in with valid credentials reports no feedback")
    func logIn_validCredentials_reportsNoFeedback() async {
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        await viewModel.logIn()
        #expect(viewModel.feedback == nil)
        #expect(!viewModel.isLoading)
    }

    @Test("An invalid form is not submitted and reports no feedback")
    func logIn_invalidForm_reportsNoFeedback() async {
        viewModel.email = "not-an-email"
        await viewModel.logIn()
        #expect(viewModel.feedback == nil)
        #expect(viewModel.emailState == .invalid)
    }

    @Test("A repository error is reported as error feedback")
    func logIn_repositoryThrowsAuthenticationError_reportsError() async {
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        repository.errorToThrow = AuthenticationError.invalidCredentials
        await viewModel.logIn()
        #expect(viewModel.feedback == .error(.invalidCredentials))
    }

    @Test("A non-AuthenticationError repository failure falls back to logInFailed")
    func logIn_repositoryThrowsGenericError_fallsBackToLogInFailed() async {
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        repository.errorToThrow = GenericError()
        await viewModel.logIn()
        #expect(viewModel.feedback == .error(.logInFailed))
    }

    // MARK: signUp

    @Test("Creates a registration from the current email and password")
    func signUp_validFields_returnsSession() async throws {
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        let session = try await viewModel.signUp()
        #expect(!session.isAnonymous)
    }

    @Test("Propagates a repository error")
    func signUp_repositoryThrows_propagatesError() async {
        repository.errorToThrow = AuthenticationError.emailAlreadyInUse
        await #expect(throws: AuthenticationError.emailAlreadyInUse) {
            try await viewModel.signUp()
        }
    }

    // MARK: signUpAnonymously

    @Test("Creates an anonymous registration and returns an anonymous session")
    func signUpAnonymously_returnsAnonymousSession() async throws {
        repository.sessionToReturn = AuthenticationSession(registrationId: UUID(), email: nil)
        let session = try await viewModel.signUpAnonymously()
        #expect(session.isAnonymous)
    }

    @Test("Propagates a repository error")
    func signUpAnonymously_repositoryThrows_propagatesError() async {
        repository.errorToThrow = AuthenticationError.logInFailed
        await #expect(throws: AuthenticationError.logInFailed) {
            try await viewModel.signUpAnonymously()
        }
    }

    // MARK: forgottenPassword

    @Test("An invalid email blocks the reset without calling the repository")
    func forgottenPassword_invalidEmail_marksFieldInvalid() async {
        viewModel.email = "not-an-email"
        await viewModel.forgottenPassword()
        #expect(viewModel.emailState == .invalid)
        #expect(viewModel.feedback == nil)
    }

    @Test("A valid email reports passwordResetSent")
    func forgottenPassword_validEmail_reportsPasswordResetSent() async {
        viewModel.email = TestData.email
        await viewModel.forgottenPassword()
        #expect(viewModel.feedback == .passwordResetSent)
    }

    @Test("A repository error while resetting the password is reported as error feedback")
    func forgottenPassword_repositoryThrows_reportsError() async {
        viewModel.email = TestData.email
        repository.errorToThrow = AuthenticationError.forgottenPasswordFailed
        await viewModel.forgottenPassword()
        #expect(viewModel.feedback == .error(.forgottenPasswordFailed))
    }
}
