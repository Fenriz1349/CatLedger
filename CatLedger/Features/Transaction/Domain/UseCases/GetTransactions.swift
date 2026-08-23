//
//  GetTransactions.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Retrieves all transactions belonging to a given profile.
final class GetTransactions {

    private let repository: TransactionProviding

    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionProviding) {
        self.repository = repository
    }

    /// Fetches all transactions for a specific profile, ordered by date descending.
    /// - Parameter profileId: The identifier of the profile.
    /// - Returns: An array of transactions belonging to the profile.
    /// - Throws: `TransactionError` if the fetch fails.
    func execute(for profileId: UUID) async throws -> [Transaction] {
        try await repository.fetchAll(for: profileId)
    }
}
