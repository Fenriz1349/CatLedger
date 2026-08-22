//
//  DeleteTransaction.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Permanently deletes a single transaction record and its embedded splits.
final class DeleteTransaction {

    private let repository: TransactionProviding

    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionProviding) {
        self.repository = repository
    }

    /// - Parameter id: The unique identifier of the transaction to delete.
    /// - Throws: `TransactionError.notFound` if no transaction matches the identifier.
    func execute(id: UUID) async throws {
        try await repository.delete(by: id)
    }
}
