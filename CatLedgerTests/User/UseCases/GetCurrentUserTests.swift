//
//  GetCurrentUserTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct GetCurrentUserTests {

    private let repository = UserDouble()
    private let useCase: GetCurrentUser

    init() {
        useCase = GetCurrentUser(repository: repository)
    }

    @Test("Returns the current user when one exists")
    func execute_userExists_returnsUser() async throws {
        let user = TestData.user()
        try await repository.save(user)
        let result = try await useCase.execute()
        #expect(result.id == user.id)
    }

    @Test("Throws notFound when no user exists")
    func execute_noUser_throwsNotFound() async throws {
        await #expect(throws: UserError.notFound) {
            try await useCase.execute()
        }
    }
}
