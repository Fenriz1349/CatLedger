//
//  LinkAnonymousRegistrationTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct LinkAnonymousRegistrationTests {

    private let repository = AuthenticationDouble()
    private let useCase: LinkAnonymousRegistration

    init() {
        useCase = LinkAnonymousRegistration(repository: repository)
    }

    @Test("Returns the non-anonymous session provided by the repository")
    func execute_validInput_returnsSession() async throws {
        let session = AuthenticationSession(registrationId: UUID(), isAnonymous: false)
        repository.sessionToReturn = session
        let result = try await useCase.execute(email: TestData.email, password: TestData.password)
        #expect(result.registrationId == session.registrationId)
        #expect(!result.isAnonymous)
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = AuthenticationError.registrationLinkingFailed
        await #expect(throws: AuthenticationError.registrationLinkingFailed) {
            try await useCase.execute(email: TestData.email, password: TestData.password)
        }
    }
}
