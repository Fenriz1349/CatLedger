//
//  TransferBetweenAccounts.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Creates an internal transfer between two accounts.
/// Produces two linked transactions:
///   - An expense on the source account
///   - An income on the destination account
/// Both are tagged `.transfer` and excluded from charts and reports.
final class TransferBetweenAccounts {

    private let repository: TransactionProviding

    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionProviding) {
        self.repository = repository
    }

    /// Executes the transfer by persisting both transactions.
    /// - Parameter input: The transfer parameters.
    /// - Throws: `TransactionError.invalidTotalAmount` if the amount is not strictly positive,
    ///   `TransactionError.redundantSplitsAccounts` if the source and destination are the same account.
    func execute(_ input: TransferFormInput) async throws {
        guard input.amount > 0 else {
            throw TransactionError.invalidTotalAmount
        }
        guard input.sourceAccountId != input.destinationAccountId else {
            throw TransactionError.redundantSplitsAccounts
        }

        let expense = Transaction(
            userId: input.userId,
            label: input.label,
            date: input.date,
            totalAmount: input.amount,
            isExpense: true,
            category: .transfer,
            splits: [TransactionSplit(accountId: input.sourceAccountId, amount: input.amount)]
        )
        let income = Transaction(
            userId: input.userId,
            label: input.label,
            date: input.date,
            totalAmount: input.amount,
            isExpense: false,
            category: .transfer,
            splits: [TransactionSplit(accountId: input.destinationAccountId, amount: input.amount)]
        )
        try await repository.save(expense)
        try await repository.save(income)
    }
}
