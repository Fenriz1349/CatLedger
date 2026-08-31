//
//  OfflineError.swift
//  CatLedger
//
//  Created by Julien Cotte on 31/08/2026.
//

import Foundation

/// Errors that occur when an operation requires network access that isn't currently available.
enum OfflineError: Error, Equatable, LocalizedError {

    /// Thrown when the device has no active network interface.
    case notConnected
    /// Thrown when the device is connected but the backend could not be reached
    /// (captive portal, VPN, server down...).
    case serverUnreachable

    /// Returns a localized, human-readable description of the error.
    var errorDescription: String? {
        switch self {
        case .notConnected:
            return String(localized: .offlineErrorNotConnected)
        case .serverUnreachable:
            return String(localized: .offlineErrorServerUnreachable)
        }
    }
}
