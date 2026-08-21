//
//  UpdateInstitutionInput.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Encapsulates all parameters required to update an existing institution.
struct UpdateInstitutionInput {
    let id: UUID
    let userId: UUID
    let name: String
    let category: InstitutionCategory
    let logoURL: String?
}
