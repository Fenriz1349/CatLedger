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
                signUpAnonymously: SignUpAnonymously(repository: authRepository),
                createAnonymousProfile: CreateAnonymousProfile(repository: profileRepository)
            )
        )
    }

    // MARK: signUp

    @Test("Signing up with valid fields returns the new session and reports no feedback")
    func signUp_validFields_reportsNoFeedback() async {
        let session = await viewModel.signUp(
            firstName: TestData.firstName,
            lastName: TestData.lastName,
            email: TestData.email,
            password: TestData.password
        )
        #expect(session != nil)
        #expect(!session!.isAnonymous)
        #expect(viewModel.feedback == nil)
    }

    @Test("A sign-up failure is reported as an authentication error")
    func signUp_signUpThrows_reportsAuthenticationError() async {
        authRepository.errorToThrow = AuthenticationError.emailAlreadyInUse
        let session = await viewModel.signUp(
            firstName: TestData.firstName,
            lastName: TestData.lastName,
            email: TestData.email,
            password: TestData.password
        )
        #expect(session == nil)
        #expect(viewModel.feedback == .authenticationError(.emailAlreadyInUse))
    }

    @Test("A profile creation failure is reported as a profile error")
    func signUp_createProfileThrows_reportsProfileError() async {
        profileRepository.errorToThrow = ProfileError.nameTooLong
        let session = await viewModel.signUp(
            firstName: TestData.firstName,
            lastName: TestData.lastName,
            email: TestData.email,
            password: TestData.password
        )
        #expect(session == nil)
        #expect(viewModel.feedback == .profileError(.nameTooLong))
    }

    @Test("A non-domain repository failure falls back to logInFailed")
    func signUp_genericError_fallsBackToLogInFailed() async {
        authRepository.errorToThrow = GenericError()
        let session = await viewModel.signUp(
            firstName: TestData.firstName,
            lastName: TestData.lastName,
            email: TestData.email,
            password: TestData.password
        )
        #expect(session == nil)
        #expect(viewModel.feedback == .authenticationError(.logInFailed))
    }

    // MARK: continueAsDemo

    @Test("Continuing as demo returns the new anonymous session and reports no feedback")
    func continueAsDemo_succeeds_reportsNoFeedback() async {
        authRepository.sessionToReturn = AuthenticationSession(registrationId: UUID(), email: nil)
        let session = await viewModel.continueAsDemo()
        #expect(session != nil)
        #expect(session!.isAnonymous)
        #expect(viewModel.feedback == nil)
    }

    @Test("A repository error while continuing as demo is reported as an authentication error")
    func continueAsDemo_repositoryThrows_reportsAuthenticationError() async {
        authRepository.errorToThrow = AuthenticationError.logInFailed
        let session = await viewModel.continueAsDemo()
        #expect(session == nil)
        #expect(viewModel.feedback == .authenticationError(.logInFailed))
    }
}
