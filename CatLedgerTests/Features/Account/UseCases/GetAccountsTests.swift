//
//  GetAccountsTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct GetAccountsTests {

    private let repository = AccountDouble()
    private let useCase: GetAccounts
    private let institutionId = UUID()

    init() {
        useCase = GetAccounts(repository: repository)
    }

    /// Seeds an account belonging to the shared institutionId.
    private func seedAccount(name: String = "Livret A", isArchived: Bool = false) async throws {
        let account = TestData.account(institutionId: institutionId, name: name, isArchived: isArchived)
        try await repository.save(account)
    }

    @Test("Returns all accounts belonging to the institution")
    func execute_returnsAllAccountsForInstitution() async throws {
        try await seedAccount(name: "Livret A")
        try await seedAccount(name: "PEL")
        let result = try await useCase.execute(for: institutionId, filter: .all)
        #expect(result.count == 2)
    }

    @Test("Does not return accounts belonging to another institution")
    func execute_doesNotReturnAccountsFromOtherInstitution() async throws {
        try await seedAccount()
        let result = try await useCase.execute(for: UUID())
        #expect(result.isEmpty)
    }

    @Test("Returns an empty array when no accounts exist")
    func execute_noAccounts_returnsEmpty() async throws {
        let result = try await useCase.execute(for: institutionId)
        #expect(result.isEmpty)
    }

    @Test("Returns only active accounts with the .active filter")
    func execute_activeFilter_returnsOnlyActiveAccounts() async throws {
        try await seedAccount(name: "Livret A", isArchived: false)
        try await seedAccount(name: "PEL", isArchived: true)
        let result = try await useCase.execute(for: institutionId, filter: .active)
        #expect(result.count == 1)
        #expect(result.first?.name == "Livret A")
    }

    @Test("Returns only archived accounts with the .archived filter")
    func execute_archivedFilter_returnsOnlyArchivedAccounts() async throws {
        try await seedAccount(name: "Livret A", isArchived: false)
        try await seedAccount(name: "PEL", isArchived: true)
        let result = try await useCase.execute(for: institutionId, filter: .archived)
        #expect(result.count == 1)
        #expect(result.first?.name == "PEL")
    }

    @Test("Returns all accounts with the .all filter")
    func execute_allFilter_returnsAllAccounts() async throws {
        try await seedAccount(name: "Livret A", isArchived: false)
        try await seedAccount(name: "PEL", isArchived: true)
        let result = try await useCase.execute(for: institutionId, filter: .all)
        #expect(result.count == 2)
    }

    @Test("Propagates a repository error")
    func execute_repositoryThrows_propagatesError() async throws {
        repository.errorToThrow = AccountError.notFound
        await #expect(throws: AccountError.notFound) {
            try await useCase.execute(for: institutionId)
        }
    }
}
