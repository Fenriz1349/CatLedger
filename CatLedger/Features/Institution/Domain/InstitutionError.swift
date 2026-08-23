//
//  InstitutionError.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Represents domain-level errors for the Institution feature.
/// These errors are thrown by UseCases, not by repositories or data sources.
enum InstitutionError: Error, Equatable, LocalizedError {

    /// Thrown when the institution name is shorter than the minimum allowed length.
    case nameTooShort

    /// Thrown when the institution name exceeds the maximum allowed length.
    case nameTooLong

    /// Thrown when an institution with the same name already exists for this profile.
    case duplicateName

    /// Thrown when no institution is found for the given identifier.
    case notFound

    /// Returns a localized, human-readable description of the error.
    var errorDescription: String? {
        switch self {
        case .nameTooShort:
            return String(localized: .institutionErrorNameTooShort)
        case .nameTooLong:
            return String(localized: .institutionErrorNameTooLong)
        case .duplicateName:
            return String(localized: .institutionErrorDuplicateName)
        case .notFound:
            return String(localized: .institutionErrorNotFound)
        }
    }
}
