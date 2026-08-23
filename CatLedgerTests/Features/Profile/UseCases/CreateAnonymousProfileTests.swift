//
//  CreateAnonymousProfileTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct CreateAnonymousProfileTests {

    private let repository = ProfileDouble()
    private let useCase: CreateAnonymousProfile

    init() {
        useCase = CreateAnonymousProfile(repository: repository)
    }

    @Test("Saves a placeholder profile to the repository")
    func execute_savesPlaceholderProfile() async throws {
        let profile = try await useCase.execute()
        let saved = try await repository.fetchCurrent()
        #expect(saved.id == profile.id)
        #expect(saved.displayName.isEmpty)
        #expect(saved.email.isEmpty)
    }
}
