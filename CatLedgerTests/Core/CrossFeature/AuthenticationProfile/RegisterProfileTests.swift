//
//  RegisterProfileTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct RegisterProfileTests {

    private let authRepository = AuthenticationDouble()
    private let profileRepository = ProfileDouble()
    private let useCase: RegisterProfile

    init() {
        useCase = RegisterProfile(
            signUp: SignUp(repository: authRepository),
            createProfile: CreateProfile(repository: profileRepository)
        )
    }

    @Test("Creates the registration and its profile")
    func execute_validInput_createsRegistrationAndProfile() async throws {
        let session = AuthenticationSession(registrationId: UUID(), email: TestData.email)
        authRepository.sessionToReturn = session

        let result = try await useCase.execute(
            firstName: TestData.firstName,
            lastName: TestData.lastName,
            email: TestData.email,
            password: TestData.password
        )

        #expect(result.registrationId == session.registrationId)
        let profile = try await profileRepository.fetch(by: session.registrationId)
        #expect(profile.firstName == TestData.firstName)
    }

    @Test("Propagates a sign-up error without creating a profile")
    func execute_signUpThrows_propagatesError() async throws {
        authRepository.errorToThrow = AuthenticationError.emailAlreadyInUse
        await #expect(throws: AuthenticationError.emailAlreadyInUse) {
            try await useCase.execute(
                firstName: TestData.firstName,
                lastName: TestData.lastName,
                email: TestData.email,
                password: TestData.password
            )
        }
        await #expect(throws: ProfileError.notFound) {
            try await profileRepository.fetch(by: UUID())
        }
    }
}
