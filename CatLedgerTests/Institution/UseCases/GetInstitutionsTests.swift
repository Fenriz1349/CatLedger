//
//  GetInstitutionsTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct GetInstitutionsTests {

    private let repository = InstitutionDouble()
    private let useCase: GetInstitutions
    private let userId = UUID()

    init() {
        useCase = GetInstitutions(repository: repository)
    }

    @Test("Returns all institutions belonging to the user")
    func execute_returnsAllInstitutionsForUser() async throws {
        try await repository.save(TestData.institution(userId: userId, name: "BNP Paribas"))
        try await repository.save(TestData.institution(userId: userId, name: "Caisse d'Épargne"))
        let result = try await useCase.execute(for: userId)
        #expect(result.count == 2)
    }

    @Test("Does not return institutions belonging to another user")
    func execute_doesNotReturnInstitutionsFromOtherUser() async throws {
        try await repository.save(TestData.institution(userId: userId))
        let result = try await useCase.execute(for: UUID())
        #expect(result.isEmpty)
    }

    @Test("Returns an empty array when no institutions exist")
    func execute_noInstitutions_returnsEmpty() async throws {
        let result = try await useCase.execute(for: userId)
        #expect(result.isEmpty)
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = InstitutionError.notFound
        await #expect(throws: InstitutionError.notFound) {
            try await useCase.execute(for: userId)
        }
    }
}
