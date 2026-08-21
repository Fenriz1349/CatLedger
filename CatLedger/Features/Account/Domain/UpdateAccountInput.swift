//
//  UpdateAccountInput.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Encapsulates all parameters required to update an existing account.
struct UpdateAccountInput {
    let id: UUID
    let institutionId: UUID
    let name: String
    let category: AccountCategory
}
