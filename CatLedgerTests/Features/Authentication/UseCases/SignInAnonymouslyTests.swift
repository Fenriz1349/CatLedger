//
//  SignInAnonymouslyTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct SignInAnonymouslyTests {

    private let repository = AuthenticationDouble()
    private let useCase: SignInAnonymously

    init() {
        useCase = SignInAnonymously(repository: repository)
    }

    @Test("Returns the anonymous session provided by the repository")
    func execute_returnsAnonymousSession() async throws {
        let session = AuthSession(registrationId: UUID(), isAnonymous: true)
        repository.sessionToReturn = session
        let result = try await useCase.execute()
        #expect(result.isAnonymous)
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = AuthError.signInFailed
        await #expect(throws: AuthError.signInFailed) {
            try await useCase.execute()
        }
    }
}
