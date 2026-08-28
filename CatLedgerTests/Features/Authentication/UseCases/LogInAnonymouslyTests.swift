//
//  SignInAnonymouslyTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct LogInAnonymouslyTests {

    private let repository = AuthenticationDouble()
    private let useCase: LogInAnonymously

    init() {
        useCase = LogInAnonymously(repository: repository)
    }

    @Test("Returns the anonymous session provided by the repository")
    func execute_returnsAnonymousSession() async throws {
        let session = AuthenticationSession(registrationId: UUID(), email: nil)
        repository.sessionToReturn = session
        let result = try await useCase.execute()
        #expect(result.isAnonymous)
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = AuthenticationError.logInFailed
        await #expect(throws: AuthenticationError.logInFailed) {
            try await useCase.execute()
        }
    }
}
