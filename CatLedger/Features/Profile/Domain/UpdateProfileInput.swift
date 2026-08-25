//
//  UpdateProfileInput.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Encapsulates all parameters required to update an existing profile.
struct UpdateProfileInput {
    let id: UUID
    let registrationId: UUID
    let firstName: String
    let lastName: String
    let email: String
    let photoURL: String?
}
