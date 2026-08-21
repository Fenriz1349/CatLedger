//
//  TransactionError.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Represents domain-level errors for the Transaction feature.
/// These errors are thrown by UseCases, not by repositories or data sources.
enum TransactionError: Error, Equatable, LocalizedError {

    /// Thrown when a transaction is created or updated with no splits.
    case missingSplits

    /// Thrown when a transaction is created or updated with the same account in different splits.
    case redundantSplitsAccounts

    /// Thrown when the sum of split amounts does not equal the transaction's totalAmount.
    case splitAmountMismatch

    /// Thrown when a split amount is zero or negative.
    case invalidSplitAmount

    /// Thrown when the totalAmount is zero or negative.
    case invalidTotalAmount

    /// Thrown when the transaction label is empty.
    case emptyLabel

    /// Thrown when no transaction is found for the given identifier.
    case notFound

    /// Thrown when the start date is after the end date in a date range query.
    case invalidDateRange

    /// Thrown when loading transactions or related data fails.
    case loadFailed

    /// Returns a localized, human-readable description of the error.
    var errorDescription: String? {
        switch self {
        case .missingSplits:
            return String(localized: .transactionErrorMissingSplits)
        case .redundantSplitsAccounts:
            return String(localized: .transactionErrorRedundantSplitsAccounts)
        case .splitAmountMismatch:
            return String(localized: .transactionErrorSplitAmountMismatch)
        case .invalidSplitAmount:
            return String(localized: .transactionErrorInvalidSplitAmount)
        case .invalidTotalAmount:
            return String(localized: .transactionErrorInvalidTotalAmount)
        case .emptyLabel:
            return String(localized: .transactionErrorEmptyLabel)
        case .notFound:
            return String(localized: .transactionErrorNotFound)
        case .invalidDateRange:
            return String(localized: .transactionErrorInvalidDateRange)
        case .loadFailed:
            return String(localized: .transactionErrorLoadFailed)
        }
    }
}
