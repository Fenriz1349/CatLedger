//
//  ExpireAnonymousProfileTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct ExpireAnonymousProfileTests {

    private let authRepository = AuthenticationDouble()
    private let profileRepository = ProfileDouble()
    private let useCase: ExpireAnonymousProfile

    init() {
        useCase = ExpireAnonymousProfile(
            isAnonymousSessionExpired: IsAnonymousSessionExpired(repository: authRepository),
            getCurrentProfile: GetCurrentProfile(repository: profileRepository),
            deleteProfile: DeleteProfile(repository: profileRepository),
            expireAnonymousSession: ExpireAnonymousSession(repository: authRepository)
        )
    }

    @Test("Deletes the profile and expires the session when it has exceeded its validity period")
    func execute_expiredSession_deletesProfileAndExpiresSession() async throws {
        let profile = TestData.profile()
        try await profileRepository.save(profile)
        authRepository.isExpired = true

        let result = try await useCase.execute(registrationId: profile.registrationId)

        #expect(result)
        #expect(authRepository.didCallExpire)
        await #expect(throws: ProfileError.notFound) {
            try await profileRepository.fetch(by: profile.registrationId)
        }
    }

    @Test("Does nothing and returns false when the session is still valid")
    func execute_validSession_returnsFalse() async throws {
        authRepository.isExpired = false
        let result = try await useCase.execute(registrationId: UUID())
        #expect(!result)
        #expect(!authRepository.didCallExpire)
    }
}
