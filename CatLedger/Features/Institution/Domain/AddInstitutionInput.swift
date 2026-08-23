//
//  AddInstitutionInput.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Encapsulates all parameters required to create a new institution.
struct AddInstitutionInput {
    let profileId: UUID
    let name: String
    let category: InstitutionCategory
    let logoURL: String?
}
