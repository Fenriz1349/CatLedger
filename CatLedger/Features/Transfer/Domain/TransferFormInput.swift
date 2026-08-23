//
//  TransferFormInput.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Parameters required to execute an internal transfer between two accounts.
struct TransferFormInput {
    /// The account money is taken from.
    let sourceAccountId: UUID
    /// The account money is sent to.
    let destinationAccountId: UUID
    /// The amount to transfer. Must be strictly positive.
    let amount: Double
    /// The date of the transfer.
    let date: Date
    /// Optional description shown on both generated transactions.
    let label: String
    /// The identifier of the profile owning both accounts.
    let profileId: UUID
}
