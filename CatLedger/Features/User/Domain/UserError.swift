//
//  UserError.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Represents domain-level errors for the User feature.
/// These errors are thrown by UseCases, not by repositories or data sources.
enum UserError: Error, Equatable, LocalizedError {

    /// Thrown when no user is found for the given identifier.
    case notFound

    /// Thrown when the user display name exceeds the maximum allowed length.
    case nameTooLong

    /// Thrown when the provided email address format is invalid.
    case invalidEmail

    /// Returns a localized, human-readable description of the error.
    var errorDescription: String? {
        switch self {
        case .notFound:
            return String(localized: .userErrorNotFound)
        case .nameTooLong:
            return String(localized: .userErrorNameTooLong)
        case .invalidEmail:
            return String(localized: .userErrorInvalidEmail)
        }
    }
}
