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
        userId: UUID = UUID(),
        name: String = "BNP Paribas",
        category: InstitutionCategory = .bank,
        isArchived: Bool = false
    ) -> Institution {
        Institution(id: id, userId: userId, name: name, category: category, isArchived: isArchived)
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
}
