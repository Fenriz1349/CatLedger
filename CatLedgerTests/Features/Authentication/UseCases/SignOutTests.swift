//
//  LogOutTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct LogOutTests {

    private let repository = AuthenticationDouble()
    private let useCase: LogOut

    init() {
        useCase = LogOut(repository: repository)
    }

    @Test("Calls logOut on the repository")
    func execute_callsLogOut() async throws {
        try await useCase.execute()
        #expect(repository.didCallLogOut)
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = AuthenticationError.logOutFailed
        await #expect(throws: AuthenticationError.logOutFailed) {
            try await useCase.execute()
        }
    }
}
