//
//  GetTransactionsByAccount.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Retrieves all transactions for a given user with a split allocated to a given account.
final class GetTransactionsByAccount {

    private let repository: TransactionProviding

    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionProviding) {
        self.repository = repository
    }

    /// Fetches transactions for a specific user holding a split on the given account.
    /// - Parameters:
    ///   - userId: The identifier of the user.
    ///   - accountId: The account whose transactions are requested.
    /// - Returns: An array of transactions, ordered by date descending.
    /// - Throws: `TransactionError` if the fetch fails.
    func execute(for userId: UUID, accountId: UUID) async throws -> [Transaction] {
        try await repository.fetchAllByAccount(for: userId, accountId: accountId)
    }
}
