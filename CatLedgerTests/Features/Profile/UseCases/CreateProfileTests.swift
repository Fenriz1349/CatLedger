//
//  CreateProfileTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct CreateProfileTests {

    private let repository = ProfileDouble()
    private let useCase: CreateProfile
    private let registrationId = UUID()

    init() {
        useCase = CreateProfile(repository: repository)
    }

    @Test("Saves a valid profile to the repository")
    func execute_validInput_savesProfile() async throws {
        let profile = try await useCase.execute(
            registrationId: registrationId,
            firstName: TestData.firstName,
            lastName: TestData.lastName
        )
        let saved = try await repository.fetch(by: registrationId)
        #expect(saved.id == profile.id)
        #expect(saved.firstName == TestData.firstName)
        #expect(saved.lastName == TestData.lastName)
    }

    @Test("Throws nameTooLong when the first name exceeds 50 characters")
    func execute_firstNameTooLong_throwsNameTooLong() async throws {
        await #expect(throws: ProfileError.nameTooLong) {
            try await useCase.execute(
                registrationId: registrationId,
                firstName: String(repeating: "A", count: 51),
                lastName: TestData.lastName
            )
        }
    }

    @Test("Throws nameTooLong when the last name exceeds 50 characters")
    func execute_lastNameTooLong_throwsNameTooLong() async throws {
        await #expect(throws: ProfileError.nameTooLong) {
            try await useCase.execute(
                registrationId: registrationId,
                firstName: TestData.firstName,
                lastName: String(repeating: "A", count: 51)
            )
        }
    }
}
