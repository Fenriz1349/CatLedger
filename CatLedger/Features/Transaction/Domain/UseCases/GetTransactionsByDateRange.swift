//
//  GetTransactionsByDateRange.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Retrieves all transactions for a given profile within a specific date range.
/// Useful for monthly or custom period statistics and charts.
final class GetTransactionsByDateRange {

    private let repository: TransactionProviding

    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionProviding) {
        self.repository = repository
    }

    /// Fetches transactions for a specific profile within a date range (inclusive).
    /// - Parameters:
    ///   - profileId: The identifier of the profile.
    ///   - fromDate: The start date of the range, inclusive.
    ///   - toDate: The end date of the range, inclusive. Defaults to the current date.
    /// - Returns: An array of transactions within the date range, ordered by date descending.
    /// - Throws: `TransactionError.invalidDateRange` if `fromDate` is after `toDate`.
    func execute(for profileId: UUID, from fromDate: Date, to toDate: Date = Date()) async throws -> [Transaction] {
        guard fromDate <= toDate else {
            throw TransactionError.invalidDateRange
        }
        return try await repository.fetchAllByDateRange(for: profileId, from: fromDate, to: toDate)
    }
}
