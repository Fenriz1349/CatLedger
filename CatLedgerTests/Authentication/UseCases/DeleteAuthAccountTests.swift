//
//  DeleteAuthAccountTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct DeleteAuthAccountTests {

    private let repository = AuthenticationDouble()
    private let useCase: DeleteAuthAccount

    init() {
        useCase = DeleteAuthAccount(repository: repository)
    }

    @Test("Calls deleteAuthAccount on the repository")
    func execute_callsDeleteAuthAccount() async throws {
        try await useCase.execute()
        #expect(repository.didCallDeleteAuthAccount)
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = AuthError.deletionFailed
        await #expect(throws: AuthError.deletionFailed) {
            try await useCase.execute()
        }
    }
}
