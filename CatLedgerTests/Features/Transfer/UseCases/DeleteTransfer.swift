//
//  DeleteTransfer.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct DeleteTransferTests {

    private let repository = TransactionDouble()
    private let useCase: DeleteTransfer
    private let profileId = UUID()
    private let sourceId = UUID()
    private let destinationId = UUID()

    init() {
        useCase = DeleteTransfer(repository: repository)
    }

    @Test("Deletes both legs of the transfer")
    func execute_deletesBothLegs() async throws {
        let transfer = TestData.transfer(profileId: profileId, sourceId: sourceId, destinationId: destinationId)
        try await repository.save(transfer.source)
        try await repository.save(transfer.destination)
        try await useCase.execute(transfer)
        let remaining = try await repository.fetchAll(for: profileId)
        #expect(remaining.isEmpty)
    }

    @Test("Throws notFound when the transfer's legs don't exist")
    func execute_unknownTransfer_throwsNotFound() async throws {
        let transfer = TestData.transfer(profileId: profileId, sourceId: sourceId, destinationId: destinationId)
        await #expect(throws: TransactionError.notFound) {
            try await useCase.execute(transfer)
        }
    }
}
