//
//  InstitutionCategory+Display.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Display metadata for InstitutionCategory: localization key and SF Symbol icon.
extension InstitutionCategory {

    /// Localized display name, backed by a compile-time-checked key from Localizable.xcstrings.
    var name: LocalizedStringResource {
        switch self {
        case .bank:         return .institutionCategoryBank
        case .insurance:    return .institutionCategoryInsurance
        case .broker:       return .institutionCategoryBroker
        case .mealVoucher:  return .institutionCategoryMealVoucher
        case .retailStore:  return .institutionCategoryRetailStore
        case .cash:         return .institutionCategoryCash
        case .other:        return .institutionCategoryOther
        }
    }

    /// SF Symbol name associated with the institution category.
    var icon: String {
        switch self {
        case .bank:         return "building.columns"
        case .insurance:    return "shield"
        case .broker:       return "chart.line.uptrend.xyaxis"
        case .mealVoucher:  return "fork.knife"
        case .retailStore:  return "bag"
        case .cash:         return "banknote"
        case .other:        return "ellipsis.circle"
        }
    }
}
