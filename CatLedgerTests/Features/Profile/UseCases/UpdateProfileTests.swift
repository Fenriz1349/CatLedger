//
//  UpdateProfileTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct UpdateProfileTests {

    private let repository = ProfileDouble()
    private let useCase: UpdateProfile

    init() {
        useCase = UpdateProfile(repository: repository)
    }

    @Test("Persists the new values for a valid update")
    func execute_validInput_updatesProfile() async throws {
        let profile = TestData.profile()
        try await repository.save(profile)
        let input = TestData.updateProfileInput(id: profile.id, registrationId: profile.registrationId)
        try await useCase.execute(input)
        let updated = try await repository.fetch(by: profile.registrationId)
        #expect(updated.firstName == input.firstName)
        #expect(updated.lastName == input.lastName)
    }

    @Test("Throws nameTooLong when the first name exceeds 50 characters")
    func execute_firstNameTooLong_throwsNameTooLong() async throws {
        let profile = TestData.profile()
        try await repository.save(profile)
        await #expect(throws: ProfileError.nameTooLong) {
            try await useCase.execute(TestData.updateProfileInput(
                id: profile.id,
                registrationId: profile.registrationId,
                firstName: String(repeating: "A", count: 51)
            ))
        }
    }

    @Test("Throws nameTooLong when the last name exceeds 50 characters")
    func execute_lastNameTooLong_throwsNameTooLong() async throws {
        let profile = TestData.profile()
        try await repository.save(profile)
        await #expect(throws: ProfileError.nameTooLong) {
            try await useCase.execute(TestData.updateProfileInput(
                id: profile.id,
                registrationId: profile.registrationId,
                lastName: String(repeating: "A", count: 51)
            ))
        }
    }
}
