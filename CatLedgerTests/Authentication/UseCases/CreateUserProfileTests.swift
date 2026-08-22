//
//  CreateUserProfileTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct CreateUserProfileTests {

    private let repository = AuthenticationDouble()
    private let useCase: CreateUserProfile

    init() {
        useCase = CreateUserProfile(repository: repository)
    }

    @Test("Returns the session provided by the repository")
    func execute_validInput_returnsSession() async throws {
        let session = AuthSession(userId: UUID(), isAnonymous: false)
        repository.sessionToReturn = session
        let result = try await useCase.execute(
            email: "batman@gotham.com",
            password: "password123",
            firstName: "Bruce",
            lastName: "Wayne"
        )
        #expect(result.userId == session.userId)
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = AuthError.emailAlreadyInUse
        await #expect(throws: AuthError.emailAlreadyInUse) {
            try await useCase.execute(
                email: "batman@gotham.com",
                password: "password123",
                firstName: "Bruce",
                lastName: "Wayne"
            )
        }
    }
}
