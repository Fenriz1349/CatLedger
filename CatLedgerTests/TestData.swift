//
//  TestData.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
@testable import CatLedger

/// Centralized factories for domain entities used across tests.
/// Keeps test setup short and consistent; pass only the fields a test actually cares about.
enum TestData {

    static func institution(
        id: UUID = UUID(),
        profileId: UUID = UUID(),
        name: String = "BNP Paribas",
        category: InstitutionCategory = .bank,
        isArchived: Bool = false
    ) -> Institution {
        Institution(id: id, profileId: profileId, name: name, category: category, isArchived: isArchived)
    }

    static func account(
        id: UUID = UUID(),
        institutionId: UUID = UUID(),
        name: String = "Compte courant",
        category: AccountCategory = .checking,
        isArchived: Bool = false
    ) -> Account {
        Account(id: id, institutionId: institutionId, name: name, category: category, isArchived: isArchived)
    }

    static func transactionSplit(
        id: UUID = UUID(),
        accountId: UUID = UUID(),
        amount: Double = 10
    ) -> TransactionSplit {
        TransactionSplit(id: id, accountId: accountId, amount: amount)
    }

    static func transaction(
        id: UUID = UUID(),
        profileId: UUID = UUID(),
        label: String = "Courses",
        date: Date = Date(),
        totalAmount: Double = 10,
        note: String? = nil,
        isExpense: Bool = true,
        category: TransactionCategory = .grocery,
        splits: [TransactionSplit]? = nil,
        isChecked: Bool = false
    ) -> Transaction {
        Transaction(
            id: id,
            profileId: profileId,
            label: label,
            date: date,
            totalAmount: totalAmount,
            note: note,
            isExpense: isExpense,
            category: category,
            splits: splits ?? [transactionSplit(amount: totalAmount)],
            isChecked: isChecked
        )
    }

    static func profile(
        id: UUID = UUID(),
        firstName: String = "Bruce",
        lastName: String = "Wayne",
        email: String = "batman@gotham.com",
        photoURL: String? = nil
    ) -> Profile {
        Profile(id: id, displayName: "\(firstName)|\(lastName)", email: email, photoURL: photoURL)
    }
}
