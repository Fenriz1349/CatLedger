//
//  AccountCategory.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Represents the category of a financial account.
/// The rawValue is used for persistence; display names and icons are resolved
/// in the Presentation and Core/Branding layers, not here.
enum AccountCategory: String, CaseIterable, Codable, Sendable {
    case checking
    case savings
    case creditCard
    case crypto
    case giftCard
    case mealVoucher
    case investment
    case cash
    case other
}
