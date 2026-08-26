//
//  SignInWithEmailTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct SignInWithEmailTests {

    private let repository = AuthenticationDouble()
    private let useCase: SignInWithEmail

    init() {
        useCase = SignInWithEmail(repository: repository)
    }

    @Test("Returns the session provided by the repository")
    func execute_validCredentials_returnsSession() async throws {
        let session = AuthenticationSession(registrationId: UUID(), email: TestData.email)
        repository.sessionToReturn = session
        let result = try await useCase.execute(email: TestData.email, password: TestData.password)
        #expect(result.registrationId == session.registrationId)
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = AuthenticationError.invalidCredentials
        await #expect(throws: AuthenticationError.invalidCredentials) {
            try await useCase.execute(email: TestData.email, password: "wrong")
        }
    }
}
