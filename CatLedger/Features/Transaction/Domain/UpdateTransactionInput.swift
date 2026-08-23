//
//  UpdateTransactionInput.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Encapsulates all parameters required to update an existing transaction.
/// `isChecked` is intentionally absent — it is toggled through its own dedicated mutation,
/// not through this general-purpose form update, and its current value is preserved instead.
struct UpdateTransactionInput {
    let id: UUID
    let profileId: UUID
    let label: String
    let date: Date
    let totalAmount: Double
    let note: String?
    let isExpense: Bool
    let category: TransactionCategory
    let splits: [TransactionSplit]
}
