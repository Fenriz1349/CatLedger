//
//  TransferBetweenAccounts.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct TransferBetweenAccountsTests {

    private let repository = TransactionDouble()
    private let useCase: TransferBetweenAccounts
    private let profileId = UUID()
    private let sourceAccountId = UUID()
    private let destinationAccountId = UUID()

    init() {
        useCase = TransferBetweenAccounts(repository: repository)
    }

    /// Returns a valid TransferFormInput with sensible defaults.
    private func makeInput(amount: Double = 100, label: String = "Virement") -> TransferFormInput {
        TransferFormInput(
            sourceAccountId: sourceAccountId,
            destinationAccountId: destinationAccountId,
            amount: amount,
            date: Date(),
            label: label,
            profileId: profileId
        )
    }

    @Test("Creates both legs of the transfer")
    func execute_createsBothLegs() async throws {
        try await useCase.execute(makeInput())
        let transactions = try await repository.fetchAll(for: profileId)
        #expect(transactions.count == 2)
    }

    @Test("Creates the expense leg on the source account")
    func execute_createsExpenseLegOnSource() async throws {
        try await useCase.execute(makeInput())
        let transactions = try await repository.fetchAll(for: profileId)
        let expense = transactions.first { $0.isExpense }
        #expect(expense?.category == .transfer)
        #expect(expense?.belongs(to: sourceAccountId) == true)
    }

    @Test("Creates the income leg on the destination account")
    func execute_createsIncomeLegOnDestination() async throws {
        try await useCase.execute(makeInput())
        let transactions = try await repository.fetchAll(for: profileId)
        let income = transactions.first { !$0.isExpense }
        #expect(income?.category == .transfer)
        #expect(income?.belongs(to: destinationAccountId) == true)
    }

    @Test("Throws invalidTotalAmount for a zero amount")
    func execute_zeroAmount_throwsInvalidTotalAmount() async throws {
        await #expect(throws: TransactionError.invalidTotalAmount) {
            try await useCase.execute(makeInput(amount: 0))
        }
    }

    @Test("Throws redundantSplitsAccounts when source and destination are the same account")
    func execute_sameAccount_throwsRedundantSplitsAccounts() async throws {
        let input = TransferFormInput(
            sourceAccountId: sourceAccountId,
            destinationAccountId: sourceAccountId,
            amount: 100,
            date: Date(),
            label: "Virement",
            profileId: profileId
        )
        await #expect(throws: TransactionError.redundantSplitsAccounts) {
            try await useCase.execute(input)
        }
    }
}
