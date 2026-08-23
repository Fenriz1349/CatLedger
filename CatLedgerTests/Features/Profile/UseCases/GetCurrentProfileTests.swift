//
//  GetCurrentProfileTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct GetCurrentProfileTests {

    private let repository = ProfileDouble()
    private let useCase: GetCurrentProfile

    init() {
        useCase = GetCurrentProfile(repository: repository)
    }

    @Test("Returns the current profile when one exists")
    func execute_profileExists_returnsProfile() async throws {
        let profile = TestData.profile()
        try await repository.save(profile)
        let result = try await useCase.execute()
        #expect(result.id == profile.id)
    }

    @Test("Throws notFound when no profile exists")
    func execute_noProfile_throwsNotFound() async throws {
        await #expect(throws: ProfileError.notFound) {
            try await useCase.execute()
        }
    }
}
