//
//  DeleteFirebaseRegistrationTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct DeleteFirebaseRegistrationTests {

    private let authRepository = AuthenticationDouble()
    private let profileRepository = ProfileDouble()
    private let useCase: DeleteFirebaseRegistration

    init() {
        useCase = DeleteFirebaseRegistration(
            getCurrentProfile: GetCurrentProfile(repository: profileRepository),
            deleteProfile: DeleteProfile(repository: profileRepository),
            deleteRegistration: DeleteRegistration(repository: authRepository)
        )
    }

    @Test("Deletes the profile then the registration")
    func execute_deletesProfileThenRegistration() async throws {
        let profile = TestData.profile()
        try await profileRepository.save(profile)

        try await useCase.execute()

        await #expect(throws: ProfileError.notFound) {
            try await profileRepository.fetchCurrent()
        }
        #expect(authRepository.didCallDeleteRegistration)
    }

    @Test("Propagates a repository error without deleting the registration")
    func execute_profileFetchThrows_propagatesError() async throws {
        profileRepository.errorToThrow = ProfileError.notFound
        await #expect(throws: ProfileError.notFound) {
            try await useCase.execute()
        }
        #expect(!authRepository.didCallDeleteRegistration)
    }
}
