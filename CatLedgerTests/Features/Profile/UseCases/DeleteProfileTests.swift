//
//  DeleteProfileTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct DeleteProfileTests {

    private let repository = ProfileDouble()
    private let useCase: DeleteProfile

    init() {
        useCase = DeleteProfile(repository: repository)
    }

    @Test("Removes the current profile record")
    func execute_existingProfile_profileDeleted() async throws {
        let profile = TestData.profile()
        try await repository.save(profile)
        try await useCase.execute(id: profile.id)
        await #expect(throws: ProfileError.notFound) {
            try await repository.fetchCurrent()
        }
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = ProfileError.notFound
        await #expect(throws: ProfileError.notFound) {
            try await useCase.execute(id: UUID())
        }
    }
}
