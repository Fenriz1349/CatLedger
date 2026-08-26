//
//  RegisterAnonymousProfileTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct RegisterAnonymousProfileTests {

    private let authRepository = AuthenticationDouble()
    private let profileRepository = ProfileDouble()
    private let useCase: RegisterAnonymousProfile

    init() {
        useCase = RegisterAnonymousProfile(
            signInAnonymously: SignInAnonymously(repository: authRepository),
            createAnonymousProfile: CreateAnonymousProfile(repository: profileRepository)
        )
    }

    @Test("Creates the anonymous registration and its placeholder profile")
    func execute_createsRegistrationAndPlaceholderProfile() async throws {
        let session = AuthenticationSession(registrationId: UUID(), email: nil)
        authRepository.sessionToReturn = session

        let result = try await useCase.execute()

        #expect(result.isAnonymous)
        let profile = try await profileRepository.fetch(by: session.registrationId)
        #expect(profile.displayName.isEmpty)
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        authRepository.errorToThrow = AuthenticationError.signInFailed
        await #expect(throws: AuthenticationError.signInFailed) {
            try await useCase.execute()
        }
    }
}
