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
            resetPassword: ResetPassword(repository: repository)
        )
    }

    // MARK: isFormValid

    @Test("Login mode is valid with just a valid email and a strong password")
    func isFormValid_login_validEmailAndPassword_returnsTrue() {
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        #expect(viewModel.isFormValid)
    }

    @Test("Creating-registration mode is invalid when the confirmation doesn't match the password")
    func isFormValid_creatingRegistration_mismatchedConfirmation_returnsFalse() {
        viewModel.isCreatingRegistration = true
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        viewModel.confirmPassword = "Mismatch123!"
        #expect(!viewModel.isFormValid)
    }

    @Test("Creating-registration mode is valid once every field matches")
    func isFormValid_creatingRegistration_allFieldsValid_returnsTrue() {
        viewModel.isCreatingRegistration = true
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        viewModel.confirmPassword = TestData.password
        #expect(viewModel.isFormValid)
    }

    // MARK: login

    @Test("Logging in with valid credentials reports signedIn")
    func login_validCredentials_reportsSignedIn() async {
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        await viewModel.login()
        #expect(viewModel.feedback == .signedIn)
        #expect(!viewModel.isLoading)
    }

    @Test("An invalid form is not submitted and reports no feedback")
    func login_invalidForm_reportsNoFeedback() async {
        viewModel.email = "not-an-email"
        await viewModel.login()
        #expect(viewModel.feedback == nil)
        #expect(viewModel.emailState == .invalid)
    }

    @Test("A repository error is reported as error feedback")
    func login_repositoryThrowsAuthenticationError_reportsError() async {
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        repository.errorToThrow = AuthenticationError.invalidCredentials
        await viewModel.login()
        #expect(viewModel.feedback == .error(.invalidCredentials))
    }

    @Test("A non-AuthenticationError repository failure falls back to signInFailed")
    func login_repositoryThrowsGenericError_fallsBackToSignInFailed() async {
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        repository.errorToThrow = GenericError()
        await viewModel.login()
        #expect(viewModel.feedback == .error(.signInFailed))
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

    // MARK: forgotPassword

    @Test("An invalid email blocks the reset without calling the repository")
    func forgotPassword_invalidEmail_marksFieldInvalid() async {
        viewModel.email = "not-an-email"
        await viewModel.forgotPassword()
        #expect(viewModel.emailState == .invalid)
        #expect(viewModel.feedback == nil)
    }

    @Test("A valid email reports passwordResetSent")
    func forgotPassword_validEmail_reportsPasswordResetSent() async {
        viewModel.email = TestData.email
        await viewModel.forgotPassword()
        #expect(viewModel.feedback == .passwordResetSent)
    }

    @Test("A repository error while resetting the password is reported as error feedback")
    func forgotPassword_repositoryThrows_reportsError() async {
        viewModel.email = TestData.email
        repository.errorToThrow = AuthenticationError.resetPasswordFailed
        await viewModel.forgotPassword()
        #expect(viewModel.feedback == .error(.resetPasswordFailed))
    }
}
