//
//  AccountError.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Represents domain-level errors for the Account feature.
/// These errors are thrown by UseCases, not by repositories or data sources.
enum AccountError: Error, Equatable, LocalizedError {

    /// Thrown when the account name is shorter than the minimum allowed length.
    case nameTooShort

    /// Thrown when the account name exceeds the maximum allowed length.
    case nameTooLong

    /// Thrown when an account with the same name already exists for this institution.
    case duplicateName

    /// Thrown when no account is found for the given identifier.
    case notFound

    /// Thrown when loading accounts fails.
    case loadFailed

    /// Thrown when archiving an account fails.
    case archiveFailed

    /// Returns a localized, human-readable description of the error.
    var errorDescription: String? {
        switch self {
        case .nameTooShort:
            return String(localized: .accountErrorNameTooShort)
        case .nameTooLong:
            return String(localized: .accountErrorNameTooLong)
        case .duplicateName:
            return String(localized: .accountErrorDuplicateName)
        case .notFound:
            return String(localized: .accountErrorNotFound)
        case .loadFailed:
            return String(localized: .accountErrorLoadFailed)
        case .archiveFailed:
            return String(localized: .accountErrorArchiveFailed)
        }
    }
}
