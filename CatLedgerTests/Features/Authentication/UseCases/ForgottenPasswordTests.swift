//
//  ForgottenPasswordTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct ForgottenPasswordTests {

    private let repository = AuthenticationDouble()
    private let useCase: ForgottenPassword

    init() {
        useCase = ForgottenPassword(repository: repository)
    }

    @Test("Succeeds for a valid email")
    func execute_validEmail_succeeds() async throws {
        try await useCase.execute(email: TestData.email)
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = AuthenticationError.forgottenPasswordFailed
        await #expect(throws: AuthenticationError.forgottenPasswordFailed) {
            try await useCase.execute(email: TestData.email)
        }
    }
}
