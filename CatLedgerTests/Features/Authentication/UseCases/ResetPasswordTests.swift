//
//  ResetPasswordTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct ResetPasswordTests {

    private let repository = AuthenticationDouble()
    private let useCase: ResetPassword

    init() {
        useCase = ResetPassword(repository: repository)
    }

    @Test("Succeeds for a valid email")
    func execute_validEmail_succeeds() async throws {
        try await useCase.execute(email: TestData.email)
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = AuthenticationError.resetPasswordFailed
        await #expect(throws: AuthenticationError.resetPasswordFailed) {
            try await useCase.execute(email: TestData.email)
        }
    }
}
