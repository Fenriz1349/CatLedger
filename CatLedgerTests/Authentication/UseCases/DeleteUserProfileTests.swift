//
//  DeleteUserProfileTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct DeleteUserProfileTests {

    private let repository = AuthenticationDouble()
    private let useCase: DeleteUserProfile

    init() {
        useCase = DeleteUserProfile(repository: repository)
    }

    @Test("Calls deleteUserProfile on the repository")
    func execute_callsDeleteUserProfile() async throws {
        try await useCase.execute()
        #expect(repository.didCallDeleteUserProfile)
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = AuthError.deletionFailed
        await #expect(throws: AuthError.deletionFailed) {
            try await useCase.execute()
        }
    }
}
