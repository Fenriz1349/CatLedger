//
//  AddTransactionTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct AddTransactionTests {

    private let repository = TransactionDouble()
    private let useCase: AddTransaction
    private let profileId = UUID()

    init() {
        useCase = AddTransaction(repository: repository)
    }

    /// Returns a valid AddTransactionInput with sensible defaults.
    private func makeInput(
        label: String = "Courses",
        totalAmount: Double = 20,
        isExpense: Bool = true,
        category: TransactionCategory = .grocery,
        splits: [TransactionSplit]? = nil
    ) -> AddTransactionInput {
        AddTransactionInput(
            profileId: profileId,
            label: label,
            date: Date(),
            totalAmount: totalAmount,
            note: nil,
            isExpense: isExpense,
            category: category,
            splits: splits ?? [TestData.transactionSplit(amount: totalAmount)]
        )
    }

    @Test("Saves a valid transaction to the repository")
    func execute_validInput_savesTransaction() async throws {
        try await useCase.execute(makeInput())
        let transactions = try await repository.fetchAll(for: profileId)
        #expect(transactions.count == 1)
    }

    @Test("Throws emptyLabel for a blank label")
    func execute_emptyLabel_throwsEmptyLabel() async throws {
        await #expect(throws: TransactionError.emptyLabel) {
            try await useCase.execute(makeInput(label: "   "))
        }
    }

    @Test("Throws invalidTotalAmount for a zero amount")
    func execute_zeroAmount_throwsInvalidTotalAmount() async throws {
        await #expect(throws: TransactionError.invalidTotalAmount) {
            try await useCase.execute(makeInput(totalAmount: 0, splits: [TestData.transactionSplit(amount: 0)]))
        }
    }

    @Test("Allows a zero amount for an initial balance")
    func execute_zeroAmountInitialBalance_succeeds() async throws {
        try await useCase.execute(makeInput(
            totalAmount: 0,
            category: .initialBalance,
            splits: [TestData.transactionSplit(amount: 0)]
        ))
        let transactions = try await repository.fetchAll(for: profileId)
        #expect(transactions.count == 1)
    }

    @Test("Throws missingSplits when no split is provided")
    func execute_missingSplits_throwsMissingSplits() async throws {
        await #expect(throws: TransactionError.missingSplits) {
            try await useCase.execute(makeInput(splits: []))
        }
    }

    @Test("Throws redundantSplitsAccounts when the same account appears twice")
    func execute_redundantSplitsAccounts_throwsRedundantSplitsAccounts() async throws {
        let accountId = UUID()
        let splits = [
            TestData.transactionSplit(accountId: accountId, amount: 10),
            TestData.transactionSplit(accountId: accountId, amount: 10)
        ]
        await #expect(throws: TransactionError.redundantSplitsAccounts) {
            try await useCase.execute(makeInput(totalAmount: 20, splits: splits))
        }
    }

    @Test("Throws invalidSplitAmount for a zero or negative split")
    func execute_invalidSplitAmount_throwsInvalidSplitAmount() async throws {
        await #expect(throws: TransactionError.invalidSplitAmount) {
            try await useCase.execute(makeInput(totalAmount: 10, splits: [TestData.transactionSplit(amount: -5)]))
        }
    }

    @Test("Throws splitAmountMismatch when splits don't sum to the total")
    func execute_splitAmountMismatch_throwsSplitAmountMismatch() async throws {
        await #expect(throws: TransactionError.splitAmountMismatch) {
            try await useCase.execute(makeInput(totalAmount: 20, splits: [TestData.transactionSplit(amount: 10)]))
        }
    }
}
