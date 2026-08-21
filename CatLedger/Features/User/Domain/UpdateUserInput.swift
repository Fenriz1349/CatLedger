//
//  UpdateUserInput.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Encapsulates all parameters required to update a user's profile.
struct UpdateUserInput {
    let id: UUID
    let firstName: String
    let lastName: String
    let email: String
    let photoURL: String?
}
