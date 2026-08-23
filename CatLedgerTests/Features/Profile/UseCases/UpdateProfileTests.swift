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

    /// Returns a valid UpdateProfileInput with sensible defaults.
    private func makeInput(
        id: UUID,
        registrationId: UUID,
        firstName: String = "Bruce",
        lastName: String = "Wayne",
        email: String = "batman@gotham.com",
        photoURL: String? = nil
    ) -> UpdateProfileInput {
        TestData.updateProfileInput(
            id: id,
            registrationId: registrationId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            photoURL: photoURL
        )
    }

    @Test("Persists the new values for a valid update")
    func execute_validInput_updatesProfile() async throws {
        let profile = TestData.profile()
        try await repository.save(profile)
        try await useCase.execute(makeInput(
            id: profile.id,
            registrationId: profile.registrationId,
            firstName: "Richard",
            lastName: "Grayson"
        ))
        let updated = try await repository.fetch(by: profile.registrationId)
        #expect(updated.firstName == "Richard")
        #expect(updated.lastName == "Grayson")
    }

    @Test("Throws nameTooLong when the first name exceeds 50 characters")
    func execute_firstNameTooLong_throwsNameTooLong() async throws {
        let profile = TestData.profile()
        try await repository.save(profile)
        await #expect(throws: ProfileError.nameTooLong) {
            try await useCase.execute(makeInput(
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
            try await useCase.execute(makeInput(
                id: profile.id,
                registrationId: profile.registrationId,
                lastName: String(repeating: "A", count: 51)
            ))
        }
    }

    @Test("Throws invalidEmail for an email missing an @")
    func execute_invalidEmail_throwsInvalidEmail() async throws {
        let profile = TestData.profile()
        try await repository.save(profile)
        await #expect(throws: ProfileError.invalidEmail) {
            try await useCase.execute(makeInput(
                id: profile.id,
                registrationId: profile.registrationId,
                email: "not-an-email"
            ))
        }
    }
}
