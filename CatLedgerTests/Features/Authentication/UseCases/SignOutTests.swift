//
//  SignOutTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct SignOutTests {

    private let repository = AuthenticationDouble()
    private let useCase: SignOut

    init() {
        useCase = SignOut(repository: repository)
    }

    @Test("Calls signOut on the repository")
    func execute_callsSignOut() async throws {
        try await useCase.execute()
        #expect(repository.didCallSignOut)
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = AuthenticationError.signOutFailed
        await #expect(throws: AuthenticationError.signOutFailed) {
            try await useCase.execute()
        }
    }
}
