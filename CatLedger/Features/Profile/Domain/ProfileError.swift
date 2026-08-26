//
//  ProfileError.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Represents domain-level errors for the Profile feature.
/// These errors are thrown by UseCases, not by repositories or data sources.
enum ProfileError: Error, Equatable, LocalizedError {

    /// Thrown when no profile is found for the given identifier.
    case notFound

    /// Thrown when the profile display name exceeds the maximum allowed length.
    case nameTooLong

    /// Returns a localized, human-readable description of the error.
    var errorDescription: String? {
        switch self {
        case .notFound:
            return String(localized: .profileErrorNotFound)
        case .nameTooLong:
            return String(localized: .profileErrorNameTooLong)
        }
    }
}
