//
//  LinkAnonymousProfileTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct LinkAnonymousProfileTests {

    private let authRepository = AuthenticationDouble()
    private let profileRepository = ProfileDouble()
    private let useCase: LinkAnonymousProfile

    init() {
        useCase = LinkAnonymousProfile(
            linkAnonymousRegistration: LinkAnonymousRegistration(repository: authRepository),
            getCurrentProfile: GetCurrentProfile(repository: profileRepository),
            updateProfile: UpdateProfile(repository: profileRepository)
        )
    }

    @Test("Links the registration and updates the profile with the real name and email")
    func execute_validInput_linksAndUpdatesProfile() async throws {
        let placeholder = TestData.profile(firstName: "", lastName: "", email: "")
        try await profileRepository.save(placeholder)
        authRepository.sessionToReturn = AuthenticationSession(registrationId: placeholder.registrationId, isAnonymous: false)

        let result = try await useCase.execute(
            firstName: "Bruce",
            lastName: "Wayne",
            email: "batman@gotham.com",
            password: "password123"
        )

        #expect(!result.isAnonymous)
        let updated = try await profileRepository.fetch(by: placeholder.registrationId)
        #expect(updated.id == placeholder.id)
        #expect(updated.firstName == "Bruce")
        #expect(updated.email == "batman@gotham.com")
    }

    @Test("Propagates a link error without updating the profile")
    func execute_linkThrows_propagatesError() async throws {
        let placeholder = TestData.profile(firstName: "", lastName: "", email: "")
        try await profileRepository.save(placeholder)
        authRepository.errorToThrow = AuthError.registrationLinkingFailed

        await #expect(throws: AuthError.registrationLinkingFailed) {
            try await useCase.execute(
                firstName: "Bruce",
                lastName: "Wayne",
                email: "batman@gotham.com",
                password: "password123"
            )
        }
    }
}
