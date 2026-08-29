//
//  AuthenticationError.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import Foundation

/// Errors that can occur during authentication operations.
enum AuthenticationError: Error, Equatable, LocalizedError {

    /// Thrown when the log-in process fails.
    case logInFailed
    /// Thrown when the log-out process fails.
    case logOutFailed
    /// Thrown when no active session is found.
    case noSessionFound
    /// Thrown when the email address is already linked to an existing registration.
    case emailAlreadyInUse
    /// Thrown when the provided password does not meet strength requirements.
    case weakPassword
    /// Thrown when the email or password is incorrect.
    case invalidCredentials
    /// Thrown when the two password entries do not match.
    case passwordsDoNotMatch
    /// Thrown when linking an anonymous registration to a permanent registration fails.
    case registrationLinkingFailed
    /// Thrown when the registration deletion process fails.
    case deletionFailed
    /// Thrown when the password reset email fails to send.
    case forgottenPasswordFailed

    /// Returns a localized, human-readable description of the error.
    var errorDescription: String? {
        switch self {
        case .logInFailed:
            return String(localized: .authErrorLogInFailed)
        case .logOutFailed:
            return String(localized: .authErrorLogOutFailed)
        case .noSessionFound:
            return String(localized: .authErrorNoSessionFound)
        case .emailAlreadyInUse:
            return String(localized: .authErrorEmailAlreadyInUse)
        case .weakPassword:
            return String(localized: .authErrorWeakPassword)
        case .invalidCredentials:
            return String(localized: .authErrorInvalidCredentials)
        case .passwordsDoNotMatch:
            return String(localized: .authErrorPasswordsDoNotMatch)
        case .registrationLinkingFailed:
            return String(localized: .authErrorRegistrationLinkingFailed)
        case .deletionFailed:
            return String(localized: .authErrorDeletionFailed)
        case .forgottenPasswordFailed:
            return String(localized: .authErrorForgottenPasswordFailed)
        }
    }
}
