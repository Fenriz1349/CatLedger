//
//  UserDouble.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
@testable import CatLedger

/// In-memory test double implementation of UserProviding.
/// Used exclusively in unit tests to isolate UseCases from persistence layers.
final class UserDouble: UserProviding {

    private var current: User?

    /// Set this to force any method to throw a specific error.
    var errorToThrow: Error?

    /// Returns the current user if one exists.
    func fetchCurrent() async throws -> User {
        if let error = errorToThrow { throw error }
        guard let user = current else { throw UserError.notFound }
        return user
    }

    /// Stores the user as the current user.
    func save(_ user: User) async throws {
        if let error = errorToThrow { throw error }
        current = user
    }

    /// Replaces the current user with the updated one.
    func update(_ user: User) async throws {
        if let error = errorToThrow { throw error }
        current = user
    }

    /// Clears the current user.
    func delete(by id: UUID) async throws {
        if let error = errorToThrow { throw error }
        current = nil
    }
}
