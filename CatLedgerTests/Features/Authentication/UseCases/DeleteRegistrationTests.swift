//
//  DeleteRegistrationTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct DeleteRegistrationTests {

    private let repository = AuthenticationDouble()
    private let useCase: DeleteRegistration

    init() {
        useCase = DeleteRegistration(repository: repository)
    }

    @Test("Calls deleteRegistration on the repository")
    func execute_callsDeleteRegistration() async throws {
        try await useCase.execute()
        #expect(repository.didCallDeleteRegistration)
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = AuthError.deletionFailed
        await #expect(throws: AuthError.deletionFailed) {
            try await useCase.execute()
        }
    }
}
