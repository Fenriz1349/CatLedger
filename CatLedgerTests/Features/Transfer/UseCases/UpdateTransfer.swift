//
//  UpdateTransfer.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct UpdateTransferTests {

    private let repository = TransactionDouble()
    private let useCase: UpdateTransfer
    private let profileId = UUID()
    private let sourceId = UUID()
    private let destinationId = UUID()
    private let sourceAccountId = UUID()
    private let destinationAccountId = UUID()

    init() {
        useCase = UpdateTransfer(repository: repository)
    }

    /// Seeds both legs and returns the corresponding Transfer.
    private func seedTransfer() async throws -> Transfer {
        let transfer = TestData.transfer(
            profileId: profileId,
            sourceId: sourceId,
            destinationId: destinationId,
            sourceAccountId: sourceAccountId,
            destinationAccountId: destinationAccountId,
            label: "Initial"
        )
        try await repository.save(transfer.source)
        try await repository.save(transfer.destination)
        return transfer
    }

    /// Returns a valid TransferFormInput with sensible defaults, scoped to the shared ids.
    private func makeInput(amount: Double = 50, label: String = "Updated") -> TransferFormInput {
        TestData.transferFormInput(
            profileId: profileId,
            sourceAccountId: sourceAccountId,
            destinationAccountId: destinationAccountId,
            amount: amount,
            label: label
        )
    }

    @Test("Updates both legs with the new values")
    func execute_validInput_updatesBothLegs() async throws {
        let transfer = try await seedTransfer()
        try await useCase.execute(transfer, input: makeInput(amount: 50, label: "Updated"))
        let source = try await repository.fetch(by: sourceId)
        let destination = try await repository.fetch(by: destinationId)
        #expect(source.totalAmount == 50)
        #expect(destination.totalAmount == 50)
        #expect(source.label == "Updated")
    }

    @Test("Throws invalidTotalAmount for a non-positive amount")
    func execute_zeroAmount_throwsInvalidTotalAmount() async throws {
        let transfer = try await seedTransfer()
        await #expect(throws: TransactionError.invalidTotalAmount) {
            try await useCase.execute(transfer, input: makeInput(amount: 0))
        }
    }

    @Test("Throws redundantSplitsAccounts when source and destination are the same account")
    func execute_sameAccount_throwsRedundantSplitsAccounts() async throws {
        let transfer = try await seedTransfer()
        let input = TestData.transferFormInput(
            profileId: profileId,
            sourceAccountId: sourceAccountId,
            destinationAccountId: sourceAccountId,
            amount: 50,
            label: "Updated"
        )
        await #expect(throws: TransactionError.redundantSplitsAccounts) {
            try await useCase.execute(transfer, input: input)
        }
    }
}
