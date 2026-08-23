//
//  LinkAnonymousAccountTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct LinkAnonymousAccountTests {

    private let repository = AuthenticationDouble()
    private let useCase: LinkAnonymousAccount

    init() {
        useCase = LinkAnonymousAccount(repository: repository)
    }

    @Test("Returns the non-anonymous session provided by the repository")
    func execute_validInput_returnsNonAnonymousSession() async throws {
        let session = AuthSession(profileId: UUID(), isAnonymous: false)
        repository.sessionToReturn = session
        let result = try await useCase.execute(
            email: "batman@gotham.com",
            password: "password123",
            firstName: "Bruce",
            lastName: "Wayne"
        )
        #expect(!result.isAnonymous)
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = AuthError.accountLinkingFailed
        await #expect(throws: AuthError.accountLinkingFailed) {
            try await useCase.execute(
                email: "batman@gotham.com",
                password: "password123",
                firstName: "Bruce",
                lastName: "Wayne"
            )
        }
    }
}
