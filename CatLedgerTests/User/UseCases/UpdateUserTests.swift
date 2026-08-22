//
//  UpdateUserTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct UpdateUserTests {

    private let repository = UserDouble()
    private let useCase: UpdateUser

    init() {
        useCase = UpdateUser(repository: repository)
    }

    /// Returns a valid UpdateUserInput with sensible defaults.
    private func makeInput(
        id: UUID,
        firstName: String = "Bruce",
        lastName: String = "Wayne",
        email: String = "batman@gotham.com",
        photoURL: String? = nil
    ) -> UpdateUserInput {
        UpdateUserInput(id: id, firstName: firstName, lastName: lastName, email: email, photoURL: photoURL)
    }

    @Test("Persists the new values for a valid update")
    func execute_validInput_updatesUser() async throws {
        let user = TestData.user()
        try await repository.save(user)
        try await useCase.execute(makeInput(id: user.id, firstName: "Richard", lastName: "Grayson"))
        let updated = try await repository.fetchCurrent()
        #expect(updated.firstName == "Richard")
        #expect(updated.lastName == "Grayson")
    }

    @Test("Throws nameTooLong when the first name exceeds 50 characters")
    func execute_firstNameTooLong_throwsNameTooLong() async throws {
        let user = TestData.user()
        try await repository.save(user)
        await #expect(throws: UserError.nameTooLong) {
            try await useCase.execute(makeInput(id: user.id, firstName: String(repeating: "A", count: 51)))
        }
    }

    @Test("Throws nameTooLong when the last name exceeds 50 characters")
    func execute_lastNameTooLong_throwsNameTooLong() async throws {
        let user = TestData.user()
        try await repository.save(user)
        await #expect(throws: UserError.nameTooLong) {
            try await useCase.execute(makeInput(id: user.id, lastName: String(repeating: "A", count: 51)))
        }
    }

    @Test("Throws invalidEmail for an email missing an @")
    func execute_invalidEmail_throwsInvalidEmail() async throws {
        let user = TestData.user()
        try await repository.save(user)
        await #expect(throws: UserError.invalidEmail) {
            try await useCase.execute(makeInput(id: user.id, email: "not-an-email"))
        }
    }
}
