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
            signUp: SignUp(repository: repository),
            signInWithEmail: SignInWithEmail(repository: repository),
            signInAnonymously: SignInAnonymously(repository: repository),
            resetPassword: ResetPassword(repository: repository)
        )
    }

    // MARK: isFormValid

    @Test("Sign-in mode is valid with just a valid email and a strong password")
    func isFormValid_signIn_validEmailAndPassword_returnsTrue() {
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        #expect(viewModel.isFormValid)
    }

    @Test("Sign-up mode is invalid when the confirmation doesn't match the password")
    func isFormValid_signUp_mismatchedConfirmation_returnsFalse() {
        viewModel.isSignUp = true
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        viewModel.firstName = TestData.firstName
        viewModel.lastName = TestData.lastName
        viewModel.confirmPassword = "Mismatch123!"
        #expect(!viewModel.isFormValid)
    }

    @Test("Sign-up mode is valid once every field matches")
    func isFormValid_signUp_allFieldsValid_returnsTrue() {
        viewModel.isSignUp = true
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        viewModel.firstName = TestData.firstName
        viewModel.lastName = TestData.lastName
        viewModel.confirmPassword = TestData.password
        #expect(viewModel.isFormValid)
    }

    // MARK: submit

    @Test("Signing in with valid credentials reports signedIn")
    func submit_signIn_validCredentials_reportsSignedIn() async {
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        await viewModel.submit()
        #expect(viewModel.feedback == .signedIn)
        #expect(!viewModel.isLoading)
    }

    @Test("Signing up with valid fields reports accountCreated")
    func submit_signUp_validFields_reportsAccountCreated() async {
        viewModel.isSignUp = true
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        viewModel.firstName = TestData.firstName
        viewModel.lastName = TestData.lastName
        viewModel.confirmPassword = TestData.password
        await viewModel.submit()
        #expect(viewModel.feedback == .accountCreated)
    }

    @Test("An invalid form is not submitted and reports no feedback")
    func submit_invalidForm_reportsNoFeedback() async {
        viewModel.email = "not-an-email"
        await viewModel.submit()
        #expect(viewModel.feedback == nil)
        #expect(viewModel.emailState == .invalid)
    }

    @Test("A repository error is reported as error feedback")
    func submit_repositoryThrowsAuthenticationError_reportsError() async {
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        repository.errorToThrow = AuthenticationError.invalidCredentials
        await viewModel.submit()
        #expect(viewModel.feedback == .error(.invalidCredentials))
    }

    @Test("A non-AuthenticationError repository failure falls back to signInFailed")
    func submit_repositoryThrowsGenericError_fallsBackToSignInFailed() async {
        viewModel.email = TestData.email
        viewModel.password = TestData.password
        repository.errorToThrow = GenericError()
        await viewModel.submit()
        #expect(viewModel.feedback == .error(.signInFailed))
    }

    // MARK: continueAnonymously

    @Test("Continuing anonymously reports continuedAsDemo")
    func continueAnonymously_succeeds_reportsContinuedAsDemo() async {
        await viewModel.continueAnonymously()
        #expect(viewModel.feedback == .continuedAsDemo)
    }

    @Test("A repository error while continuing anonymously is reported as error feedback")
    func continueAnonymously_repositoryThrows_reportsError() async {
        repository.errorToThrow = AuthenticationError.signInFailed
        await viewModel.continueAnonymously()
        #expect(viewModel.feedback == .error(.signInFailed))
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
