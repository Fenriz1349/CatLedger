//
//  SignUpTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct SignUpTests {

    private let repository = AuthenticationDouble()
    private let useCase: SignUp

    init() {
        useCase = SignUp(repository: repository)
    }

    @Test("Returns the session provided by the repository")
    func execute_validInput_returnsSession() async throws {
        let session = AuthenticationSession(registrationId: UUID(), isAnonymous: false)
        repository.sessionToReturn = session
        let result = try await useCase.execute(email: TestData.email, password: TestData.password)
        #expect(result.registrationId == session.registrationId)
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = AuthenticationError.emailAlreadyInUse
        await #expect(throws: AuthenticationError.emailAlreadyInUse) {
            try await useCase.execute(email: TestData.email, password: TestData.password)
        }
    }
}
