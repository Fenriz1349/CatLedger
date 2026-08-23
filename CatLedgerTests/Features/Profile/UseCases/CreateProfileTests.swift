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

    init() {
        useCase = CreateProfile(repository: repository)
    }

    @Test("Saves a valid profile to the repository")
    func execute_validInput_savesProfile() async throws {
        let profile = try await useCase.execute(firstName: "Bruce", lastName: "Wayne", email: "batman@gotham.com")
        let saved = try await repository.fetchCurrent()
        #expect(saved.id == profile.id)
        #expect(saved.firstName == "Bruce")
        #expect(saved.lastName == "Wayne")
    }

    @Test("Throws nameTooLong when the first name exceeds 50 characters")
    func execute_firstNameTooLong_throwsNameTooLong() async throws {
        await #expect(throws: ProfileError.nameTooLong) {
            try await useCase.execute(
                firstName: String(repeating: "A", count: 51),
                lastName: "Wayne",
                email: "batman@gotham.com"
            )
        }
    }

    @Test("Throws nameTooLong when the last name exceeds 50 characters")
    func execute_lastNameTooLong_throwsNameTooLong() async throws {
        await #expect(throws: ProfileError.nameTooLong) {
            try await useCase.execute(
                firstName: "Bruce",
                lastName: String(repeating: "A", count: 51),
                email: "batman@gotham.com"
            )
        }
    }

    @Test("Throws invalidEmail for an email missing an @")
    func execute_invalidEmail_throwsInvalidEmail() async throws {
        await #expect(throws: ProfileError.invalidEmail) {
            try await useCase.execute(firstName: "Bruce", lastName: "Wayne", email: "not-an-email")
        }
    }
}
