//
//  AuthenticationProfileViewModelTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 27/08/2026.
//

import Foundation
import Testing
import CustomTextFields
@testable import CatLedger

@MainActor
struct AuthenticationProfileViewModelTests {

    private struct GenericError: Error {}

    private let authRepository = AuthenticationDouble()
    private let profileRepository = ProfileDouble()
    private let viewModel: AuthenticationProfileViewModel

    init() {
        viewModel = AuthenticationProfileViewModel(
            registerProfile: RegisterProfile(
                signUp: SignUp(repository: authRepository),
                createProfile: CreateProfile(repository: profileRepository)
            ),
            registerAnonymousProfile: RegisterAnonymousProfile(
                signInAnonymously: LogInAnonymously(repository: authRepository),
                createAnonymousProfile: CreateAnonymousProfile(repository: profileRepository)
            )
        )
    }

    @Test("isFormValid is false when a name field is empty")
    func isFormValid_emptyFirstName_returnsFalse() {
        viewModel.firstName = ""
        viewModel.lastName = TestData.lastName
        #expect(!viewModel.isFormValid)
    }

    @Test("isFormValid is true when both names are filled")
    func isFormValid_bothNamesFilled_returnsTrue() {
        viewModel.firstName = TestData.firstName
        viewModel.lastName = TestData.lastName
        #expect(viewModel.isFormValid)
    }

    @Test("Creating an account with valid fields reports accountCreated")
    func createAccount_validFields_reportsAccountCreated() async {
        viewModel.firstName = TestData.firstName
        viewModel.lastName = TestData.lastName
        await viewModel.createAccount(email: TestData.email, password: TestData.password)
        #expect(viewModel.feedback == .accountCreated)
    }

    @Test("An invalid form is not submitted and reports no feedback")
    func createAccount_invalidForm_reportsNoFeedback() async {
        viewModel.firstName = ""
        viewModel.lastName = TestData.lastName
        await viewModel.createAccount(email: TestData.email, password: TestData.password)
        #expect(viewModel.feedback == nil)
        #expect(viewModel.firstNameState == .invalid)
    }

    @Test("A sign-up failure is reported as an authentication error")
    func createAccount_signUpThrows_reportsAuthenticationError() async {
        viewModel.firstName = TestData.firstName
        viewModel.lastName = TestData.lastName
        authRepository.errorToThrow = AuthenticationError.emailAlreadyInUse
        await viewModel.createAccount(email: TestData.email, password: TestData.password)
        #expect(viewModel.feedback == .authenticationError(.emailAlreadyInUse))
    }

    @Test("A profile creation failure is reported as a profile error")
    func createAccount_createProfileThrows_reportsProfileError() async {
        viewModel.firstName = TestData.firstName
        viewModel.lastName = TestData.lastName
        profileRepository.errorToThrow = ProfileError.nameTooLong
        await viewModel.createAccount(email: TestData.email, password: TestData.password)
        #expect(viewModel.feedback == .profileError(.nameTooLong))
    }

    @Test("A non-domain repository failure falls back to signInFailed")
    func createAccount_genericError_fallsBackToSignInFailed() async {
        viewModel.firstName = TestData.firstName
        viewModel.lastName = TestData.lastName
        authRepository.errorToThrow = GenericError()
        await viewModel.createAccount(email: TestData.email, password: TestData.password)
        #expect(viewModel.feedback == .authenticationError(.signInFailed))
    }

    @Test("Continuing as demo reports continuedAsDemo")
    func continueAsDemo_succeeds_reportsContinuedAsDemo() async {
        await viewModel.continueAsDemo()
        #expect(viewModel.feedback == .continuedAsDemo)
    }

    @Test("A repository error while continuing as demo is reported as an authentication error")
    func continueAsDemo_repositoryThrows_reportsAuthenticationError() async {
        authRepository.errorToThrow = AuthenticationError.signInFailed
        await viewModel.continueAsDemo()
        #expect(viewModel.feedback == .authenticationError(.signInFailed))
    }
}
