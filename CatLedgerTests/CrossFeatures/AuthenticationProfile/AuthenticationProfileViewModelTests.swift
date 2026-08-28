//
//  AuthenticationProfileViewModelTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 27/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

@MainActor
struct AuthenticationProfileViewModelTests {

    private struct GenericError: Error {}

    /// Captures the session passed to `onAuthenticated`, so tests can assert whether and with
    /// what it was called.
    @MainActor
    private final class AuthenticatedSpy {
        var session: AuthenticationSession?
    }

    private let authRepository = AuthenticationDouble()
    private let profileRepository = ProfileDouble()
    private let authenticatedSpy = AuthenticatedSpy()
    private let viewModel: AuthenticationProfileViewModel

    init() {
        let spy = authenticatedSpy
        viewModel = AuthenticationProfileViewModel(
            registerProfile: RegisterProfile(
                signUp: SignUp(repository: authRepository),
                createProfile: CreateProfile(repository: profileRepository)
            ),
            registerAnonymousProfile: RegisterAnonymousProfile(
                signUpAnonymously: SignUpAnonymously(repository: authRepository),
                createAnonymousProfile: CreateAnonymousProfile(repository: profileRepository)
            ),
            onAuthenticated: { session in spy.session = session }
        )
    }

    // MARK: isProfileFormValid

    @Test("isProfileFormValid is false when a name field is empty")
    func isProfileFormValid_emptyFirstName_returnsFalse() {
        viewModel.firstName = ""
        viewModel.lastName = TestData.lastName
        #expect(!viewModel.isProfileFormValid)
    }

    @Test("isProfileFormValid is true when both names are filled")
    func isProfileFormValid_bothNamesFilled_returnsTrue() {
        viewModel.firstName = TestData.firstName
        viewModel.lastName = TestData.lastName
        #expect(viewModel.isProfileFormValid)
    }

    // MARK: signUp

    @Test("Signing up with valid fields calls onAuthenticated and reports no feedback")
    func signUp_validFields_callsOnAuthenticatedAndReportsNoFeedback() async {
        viewModel.firstName = TestData.firstName
        viewModel.lastName = TestData.lastName
        await viewModel.signUp(email: TestData.email, password: TestData.password)
        #expect(authenticatedSpy.session != nil)
        #expect(authenticatedSpy.session?.isAnonymous == false)
        #expect(viewModel.feedback == nil)
    }

    @Test("A sign-up failure is reported as an authentication error")
    func signUp_signUpThrows_reportsAuthenticationError() async {
        viewModel.firstName = TestData.firstName
        viewModel.lastName = TestData.lastName
        authRepository.errorToThrow = AuthenticationError.emailAlreadyInUse
        await viewModel.signUp(email: TestData.email, password: TestData.password)
        #expect(authenticatedSpy.session == nil)
        #expect(viewModel.feedback == .authenticationError(.emailAlreadyInUse))
    }

    @Test("A profile creation failure is reported as a profile error")
    func signUp_createProfileThrows_reportsProfileError() async {
        viewModel.firstName = TestData.firstName
        viewModel.lastName = TestData.lastName
        profileRepository.errorToThrow = ProfileError.nameTooLong
        await viewModel.signUp(email: TestData.email, password: TestData.password)
        #expect(authenticatedSpy.session == nil)
        #expect(viewModel.feedback == .profileError(.nameTooLong))
    }

    @Test("A non-domain repository failure falls back to logInFailed")
    func signUp_genericError_fallsBackToLogInFailed() async {
        viewModel.firstName = TestData.firstName
        viewModel.lastName = TestData.lastName
        authRepository.errorToThrow = GenericError()
        await viewModel.signUp(email: TestData.email, password: TestData.password)
        #expect(authenticatedSpy.session == nil)
        #expect(viewModel.feedback == .authenticationError(.logInFailed))
    }

    // MARK: continueAsDemo

    @Test("Continuing as demo calls onAuthenticated and reports no feedback")
    func continueAsDemo_succeeds_callsOnAuthenticatedAndReportsNoFeedback() async {
        authRepository.sessionToReturn = AuthenticationSession(registrationId: UUID(), email: nil)
        await viewModel.continueAsDemo()
        #expect(authenticatedSpy.session != nil)
        #expect(authenticatedSpy.session?.isAnonymous == true)
        #expect(viewModel.feedback == nil)
    }

    @Test("A repository error while continuing as demo is reported as an authentication error")
    func continueAsDemo_repositoryThrows_reportsAuthenticationError() async {
        authRepository.errorToThrow = AuthenticationError.logInFailed
        await viewModel.continueAsDemo()
        #expect(authenticatedSpy.session == nil)
        #expect(viewModel.feedback == .authenticationError(.logInFailed))
    }
}
