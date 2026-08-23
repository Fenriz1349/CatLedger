//
//  GetTransactionsByCategory.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Retrieves all transactions for a given profile filtered by transaction category.
/// Useful for category-based charts and statistics.
final class GetTransactionsByCategory {

    private let repository: TransactionProviding

    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionProviding) {
        self.repository = repository
    }

    /// Fetches transactions for a specific profile filtered by category.
    /// - Parameters:
    ///   - profileId: The identifier of the profile.
    ///   - category: The transaction category to filter by.
    /// - Returns: An array of transactions matching the given category, ordered by date descending.
    /// - Throws: `TransactionError` if the fetch fails.
    func execute(for profileId: UUID, category: TransactionCategory) async throws -> [Transaction] {
        try await repository.fetchAllByCategory(for: profileId, category: category)
    }
}
