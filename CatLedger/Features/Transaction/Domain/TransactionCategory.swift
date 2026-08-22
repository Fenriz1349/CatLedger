//
//  TransactionCategory.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Represents the category of a transaction.
/// The rawValue is used for persistence; display names and icons are resolved
/// in the Presentation and Core/Branding layers, not here.
enum TransactionCategory: String, CaseIterable, Codable, Sendable {

    // MARK: Daily
    case grocery
    case restaurant
    case bar

    // MARK: Transport
    case transport
    case car

    // MARK: Home & Life
    case rent
    case utilities
    case health
    case education

    // MARK: Leisure
    case leisure
    case shopping
    case travel
    case subscription

    // MARK: Income
    case salary
    case social
    case investment
    case sale

    // MARK: Misc
    case gift
    case other
    case initialBalance
    case transfer

    /// Whether this category should appear in expense/income charts and reports.
    /// Transfers and initial balances are internal operations, not real financial events.
    var isReportable: Bool {
        self != .transfer && self != .initialBalance
    }

    /// Whether this category can be manually selected by the user in a transaction form.
    /// Transfers and initial balances are created via dedicated flows, not free-form entry.
    var isUserSelectable: Bool {
        self != .transfer && self != .initialBalance
    }

    /// Whether this category appears in the transaction lists.
    /// An initial balance is account setup, shown and edited from its own account — not activity.
    var isListed: Bool {
        self != .initialBalance
    }
}
