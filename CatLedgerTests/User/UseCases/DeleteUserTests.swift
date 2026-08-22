//
//  DeleteUserTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct DeleteUserTests {

    private let repository = UserDouble()
    private let useCase: DeleteUser

    init() {
        useCase = DeleteUser(repository: repository)
    }

    @Test("Removes the current user record")
    func execute_existingUser_userDeleted() async throws {
        let user = TestData.user()
        try await repository.save(user)
        try await useCase.execute(id: user.id)
        await #expect(throws: UserError.notFound) {
            try await repository.fetchCurrent()
        }
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = UserError.notFound
        await #expect(throws: UserError.notFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
