//
//  AccountCategory+Display.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Display metadata for AccountCategory: localized name and SF Symbol icon.
/// Kept out of the Domain layer, which stays free of presentation concerns.
extension AccountCategory {

    /// Localized display name, backed by a compile-time-checked key from Localizable.xcstrings.
    var name: LocalizedStringResource {
        switch self {
        case .checking:     return .accountCategoryChecking
        case .savings:      return .accountCategorySavings
        case .creditCard:   return .accountCategoryCreditCard
        case .crypto:       return .accountCategoryCrypto
        case .giftCard:     return .accountCategoryGiftCard
        case .mealVoucher:  return .accountCategoryMealVoucher
        case .investment:   return .accountCategoryInvestment
        case .cash:         return .accountCategoryCash
        case .other:        return .accountCategoryOther
        }
    }

    /// SF Symbol name associated with the account category.
    var icon: String {
        switch self {
        case .checking:     return "banknote"
        case .savings:      return "eurosign.bank.building"
        case .creditCard:   return "creditcard"
        case .crypto:       return "bitcoinsign.circle"
        case .giftCard:     return "gift"
        case .mealVoucher:  return "fork.knife"
        case .investment:   return "chart.line.uptrend.xyaxis"
        case .cash:         return "dollarsign.circle"
        case .other:        return "ellipsis.circle"
        }
    }
}
