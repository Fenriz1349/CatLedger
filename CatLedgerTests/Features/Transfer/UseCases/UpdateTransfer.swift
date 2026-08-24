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

    init() {
        useCase = UpdateTransfer(repository: repository)
    }

    /// Seeds both legs and returns the corresponding Transfer.
    private func seedTransfer() async throws -> Transfer {
        let transfer = TestData.transfer()
        try await repository.save(transfer.source)
        try await repository.save(transfer.destination)
        return transfer
    }

    /// Returns a valid TransferFormInput with sensible defaults, scoped to the given transfer's legs.
    private func makeInput(for transfer: Transfer, amount: Double = 50) -> TransferFormInput {
        TestData.transferFormInput(
            profileId: transfer.source.profileId,
            sourceAccountId: transfer.source.splits[0].accountId,
            destinationAccountId: transfer.destination.splits[0].accountId,
            amount: amount
        )
    }

    @Test("Updates both legs with the new values")
    func execute_validInput_updatesBothLegs() async throws {
        let transfer = try await seedTransfer()
        let input = makeInput(for: transfer)
        try await useCase.execute(transfer, input: input)
        let source = try await repository.fetch(by: transfer.source.id)
        let destination = try await repository.fetch(by: transfer.destination.id)
        #expect(source.totalAmount == input.amount)
        #expect(destination.totalAmount == input.amount)
        #expect(source.label == input.label)
    }

    @Test("Throws invalidTotalAmount for a non-positive amount")
    func execute_zeroAmount_throwsInvalidTotalAmount() async throws {
        let transfer = try await seedTransfer()
        await #expect(throws: TransactionError.invalidTotalAmount) {
            try await useCase.execute(transfer, input: makeInput(for: transfer, amount: 0))
        }
    }

    @Test("Throws redundantSplitsAccounts when source and destination are the same account")
    func execute_sameAccount_throwsRedundantSplitsAccounts() async throws {
        let transfer = try await seedTransfer()
        let input = TestData.transferFormInput(
            profileId: transfer.source.profileId,
            sourceAccountId: transfer.source.splits[0].accountId,
            destinationAccountId: transfer.source.splits[0].accountId,
            amount: 50
        )
        await #expect(throws: TransactionError.redundantSplitsAccounts) {
            try await useCase.execute(transfer, input: input)
        }
    }
}
