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

    /// Thrown when persisting a profile update fails for a reason with no more specific case.
    case updateFailed

    /// Thrown when persisting a new profile fails for a reason with no more specific case.
    case creationFailed

    /// Returns a localized, human-readable description of the error.
    var errorDescription: String? {
        switch self {
        case .notFound:
            return String(localized: .profileErrorNotFound)
        case .nameTooLong:
            return String(localized: .profileErrorNameTooLong)
        case .updateFailed:
            return String(localized: .profileErrorUpdateFailed)
        case .creationFailed:
            return String(localized: .profileErrorCreationFailed)
        }
    }
}
