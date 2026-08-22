//
//  TransactionCategory+Display.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Display metadata for TransactionCategory: localized name and SF Symbol icon.
/// Kept out of the Domain layer, which stays free of presentation concerns.
extension TransactionCategory {

    /// Localized display name, backed by a compile-time-checked key from Localizable.xcstrings.
    var name: LocalizedStringResource {
        switch self {
        case .grocery:        return .transactionCategoryGrocery
        case .restaurant:     return .transactionCategoryRestaurant
        case .bar:            return .transactionCategoryBar
        case .transport:      return .transactionCategoryTransport
        case .car:            return .transactionCategoryCar
        case .rent:           return .transactionCategoryRent
        case .utilities:      return .transactionCategoryUtilities
        case .health:         return .transactionCategoryHealth
        case .education:      return .transactionCategoryEducation
        case .leisure:        return .transactionCategoryLeisure
        case .shopping:       return .transactionCategoryShopping
        case .travel:         return .transactionCategoryTravel
        case .subscription:   return .transactionCategorySubscription
        case .salary:         return .transactionCategorySalary
        case .social:         return .transactionCategorySocial
        case .investment:     return .transactionCategoryInvestment
        case .sale:           return .transactionCategorySale
        case .gift:           return .transactionCategoryGift
        case .other:          return .transactionCategoryOther
        case .initialBalance: return .transactionCategoryInitialBalance
        case .transfer:       return .transactionCategoryTransfer
        }
    }

    /// SF Symbol name associated with the transaction category.
    var icon: String {
        switch self {
        case .grocery:        return "basket"
        case .restaurant:     return "fork.knife"
        case .bar:            return "wineglass"
        case .transport:      return "tram"
        case .car:            return "car"
        case .rent:           return "house"
        case .utilities:      return "bolt"
        case .health:         return "cross.case"
        case .education:      return "graduationcap"
        case .leisure:        return "gamecontroller"
        case .shopping:       return "bag"
        case .travel:         return "airplane"
        case .subscription:   return "repeat"
        case .salary:         return "banknote"
        case .social:         return "person.2"
        case .investment:     return "chart.line.uptrend.xyaxis"
        case .sale:           return "tag"
        case .gift:           return "gift"
        case .other:          return "ellipsis.circle"
        case .initialBalance: return "flag"
        case .transfer:       return "arrow.left.arrow.right"
        }
    }
}
