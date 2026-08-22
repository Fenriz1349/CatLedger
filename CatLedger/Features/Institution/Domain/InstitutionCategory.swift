//
//  InstitutionCategory.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Represents the category of a financial institution.
/// The rawValue is used for persistence; display names and icons are resolved
/// in the Presentation and Core/Branding layers, not here.
enum InstitutionCategory: String, CaseIterable, Codable, Sendable {
    case bank
    case insurance
    case broker
    case mealVoucher
    case retailStore
    case cash
    case other
}
