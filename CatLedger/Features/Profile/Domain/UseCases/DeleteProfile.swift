//
//  DeleteProfile.swift
//  CatLedger
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation

/// Permanently deletes a single profile record.
final class DeleteProfile {

    private let repository: ProfileProviding

    /// - Parameter repository: The data contract for profile persistence.
    init(repository: ProfileProviding) {
        self.repository = repository
    }

    /// - Parameter id: The internal identifier of the profile to delete.
    func execute(id: UUID) async throws {
        try await repository.delete(by: id)
    }
}
