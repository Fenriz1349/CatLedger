//
//  AccountDisplayItem.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Pairs an Account with its resolved institution name for display purposes.
/// Used wherever a picker or list needs to show "Account • Institution".
struct AccountDisplayItem: Identifiable {

    let account: Account
    let institutionName: String

    var id: UUID { account.id }

    /// Formatted label combining account name and institution name.
    var displayLabel: String { "\(account.name) • \(institutionName)" }
}
