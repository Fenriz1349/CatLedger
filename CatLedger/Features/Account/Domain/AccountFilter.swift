//
//  AccountFilter.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Defines the filter to apply when fetching accounts.
enum AccountFilter {
    /// Returns only active (non-archived) accounts.
    case active
    /// Returns only archived accounts.
    case archived
    /// Returns all accounts regardless of their archived status.
    case all
}
