//
//  DeleteUser.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Permanently deletes a single user record.
final class DeleteUser {

    private let repository: UserProviding

    /// - Parameter repository: The data contract for user persistence.
    init(repository: UserProviding) {
        self.repository = repository
    }

    /// - Parameter id: The internal identifier of the user to delete.
    func execute(id: UUID) async throws {
        try await repository.delete(by: id)
    }
}
