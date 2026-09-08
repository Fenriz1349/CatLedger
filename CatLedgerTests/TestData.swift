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

    /// A valid, reusable email address. Centralized so a change to email validation
    /// or format never requires touching every test that needs "some valid email".
    static let email = "batman@gotham.com"

    /// A password satisfying the current strength rules. Centralized so a change to
    /// password strength rules only requires updating this one value, not every test.
    static let password = "Test123!"

    /// A valid first name. Centralized so a change to name-validation rules only
    /// requires updating this one value, not every test.
    static let firstName = "Bruce"

    /// A valid last name. Centralized so a change to name-validation rules only
    /// requires updating this one value, not every test.
    static let lastName = "Wayne"

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

    static func transfer(
        profileId: UUID = UUID(),
        sourceId: UUID = UUID(),
        destinationId: UUID = UUID(),
        sourceAccountId: UUID = UUID(),
        destinationAccountId: UUID = UUID(),
        amount: Double = 100,
        label: String = "Virement"
    ) -> Transfer {
        let source = transaction(
            id: sourceId,
            profileId: profileId,
            label: label,
            totalAmount: amount,
            isExpense: true,
            category: .transfer,
            splits: [transactionSplit(accountId: sourceAccountId, amount: amount)]
        )
        let destination = transaction(
            id: destinationId,
            profileId: profileId,
            label: label,
            totalAmount: amount,
            isExpense: false,
            category: .transfer,
            splits: [transactionSplit(accountId: destinationAccountId, amount: amount)]
        )
        return Transfer(source: source, destination: destination)
    }

    static func profile(
        id: UUID = UUID(),
        registrationId: UUID = UUID(),
        firstName: String = TestData.firstName,
        lastName: String = TestData.lastName,
        photoURL: String? = nil,
        updatedAt: Date = Date()
    ) -> Profile {
        Profile(
            id: id,
            registrationId: registrationId,
            displayName: "\(firstName)|\(lastName)",
            photoURL: photoURL,
            updatedAt: updatedAt
        )
    }

    static func addInstitutionInput(
        profileId: UUID = UUID(),
        name: String = "BNP Paribas",
        category: InstitutionCategory = .bank,
        logoURL: String? = nil
    ) -> AddInstitutionInput {
        AddInstitutionInput(profileId: profileId, name: name, category: category, logoURL: logoURL)
    }

    static func updateInstitutionInput(
        id: UUID = UUID(),
        profileId: UUID = UUID(),
        name: String = "Caisse d'Épargne",
        category: InstitutionCategory = .bank,
        logoURL: String? = nil
    ) -> UpdateInstitutionInput {
        UpdateInstitutionInput(id: id, profileId: profileId, name: name, category: category, logoURL: logoURL)
    }

    static func updateAccountInput(
        id: UUID = UUID(),
        institutionId: UUID = UUID(),
        name: String = "PEL",
        category: AccountCategory = .savings
    ) -> UpdateAccountInput {
        UpdateAccountInput(id: id, institutionId: institutionId, name: name, category: category)
    }

    static func addTransactionInput(
        profileId: UUID = UUID(),
        label: String = "Courses",
        date: Date = Date(),
        totalAmount: Double = 20,
        note: String? = nil,
        isExpense: Bool = true,
        category: TransactionCategory = .grocery,
        splits: [TransactionSplit]? = nil
    ) -> AddTransactionInput {
        AddTransactionInput(
            profileId: profileId,
            label: label,
            date: date,
            totalAmount: totalAmount,
            note: note,
            isExpense: isExpense,
            category: category,
            splits: splits ?? [transactionSplit(amount: totalAmount)]
        )
    }

    static func updateTransactionInput(
        id: UUID = UUID(),
        profileId: UUID = UUID(),
        label: String = "Restaurant",
        date: Date = Date(),
        totalAmount: Double = 20,
        note: String? = nil,
        isExpense: Bool = true,
        category: TransactionCategory = .restaurant,
        splits: [TransactionSplit]? = nil
    ) -> UpdateTransactionInput {
        UpdateTransactionInput(
            id: id,
            profileId: profileId,
            label: label,
            date: date,
            totalAmount: totalAmount,
            note: note,
            isExpense: isExpense,
            category: category,
            splits: splits ?? [transactionSplit(amount: totalAmount)]
        )
    }

    static func transferFormInput(
        profileId: UUID = UUID(),
        sourceAccountId: UUID = UUID(),
        destinationAccountId: UUID = UUID(),
        amount: Double = 100,
        date: Date = Date(),
        label: String = "Virement modifié"
    ) -> TransferFormInput {
        TransferFormInput(
            sourceAccountId: sourceAccountId,
            destinationAccountId: destinationAccountId,
            amount: amount,
            date: date,
            label: label,
            profileId: profileId
        )
    }

    static func updateProfileInput(
        id: UUID = UUID(),
        registrationId: UUID = UUID(),
        firstName: String = "Richard",
        lastName: String = "Grayson",
        photoURL: String? = nil
    ) -> UpdateProfileInput {
        UpdateProfileInput(
            id: id,
            registrationId: registrationId,
            firstName: firstName,
            lastName: lastName,
            photoURL: photoURL
        )
    }
}
