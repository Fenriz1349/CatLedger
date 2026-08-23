//
//  UpdateTransactionTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct UpdateTransactionTests {

    private let repository = TransactionDouble()
    private let useCase: UpdateTransaction
    private let profileId = UUID()

    init() {
        useCase = UpdateTransaction(repository: repository)
    }

    /// Returns a valid UpdateTransactionInput with sensible defaults, scoped to the shared profileId.
    private func makeInput(
        id: UUID,
        label: String = "Restaurant",
        totalAmount: Double = 20,
        splits: [TransactionSplit]? = nil
    ) -> UpdateTransactionInput {
        TestData.updateTransactionInput(
            id: id,
            profileId: profileId,
            label: label,
            totalAmount: totalAmount,
            splits: splits
        )
    }

    @Test("Persists the new values for a valid update")
    func execute_validInput_updatesTransaction() async throws {
        let transaction = TestData.transaction(profileId: profileId)
        try await repository.save(transaction)
        try await useCase.execute(makeInput(id: transaction.id, label: "Restaurant"))
        let updated = try await repository.fetch(by: transaction.id)
        #expect(updated.label == "Restaurant")
    }

    @Test("Preserves isChecked from the existing transaction")
    func execute_validInput_preservesIsChecked() async throws {
        let transaction = TestData.transaction(profileId: profileId, isChecked: true)
        try await repository.save(transaction)
        try await useCase.execute(makeInput(id: transaction.id))
        let updated = try await repository.fetch(by: transaction.id)
        #expect(updated.isChecked)
    }

    @Test("Throws emptyLabel for a blank label")
    func execute_emptyLabel_throwsEmptyLabel() async throws {
        let transaction = TestData.transaction(profileId: profileId)
        try await repository.save(transaction)
        await #expect(throws: TransactionError.emptyLabel) {
            try await useCase.execute(makeInput(id: transaction.id, label: "   "))
        }
    }

    @Test("Throws missingSplits when no split is provided")
    func execute_missingSplits_throwsMissingSplits() async throws {
        let transaction = TestData.transaction(profileId: profileId)
        try await repository.save(transaction)
        await #expect(throws: TransactionError.missingSplits) {
            try await useCase.execute(makeInput(id: transaction.id, splits: []))
        }
    }

    @Test("Throws splitAmountMismatch when splits don't sum to the total")
    func execute_splitAmountMismatch_throwsSplitAmountMismatch() async throws {
        let transaction = TestData.transaction(profileId: profileId)
        try await repository.save(transaction)
        await #expect(throws: TransactionError.splitAmountMismatch) {
            try await useCase.execute(makeInput(
                id: transaction.id,
                totalAmount: 20,
                splits: [TestData.transactionSplit(amount: 10)]
            ))
        }
    }
}
