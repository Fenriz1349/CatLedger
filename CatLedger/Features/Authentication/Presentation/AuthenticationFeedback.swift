//
//  AuthenticationFeedback.swift
//  CatLedger
//
//  Created by Julien Cotte on 25/08/2026.
//

import Foundation
import Toasty

/// Every user-facing outcome the Authentication screen can produce.
/// Owns the toast text and style for each case, so the ViewModel only ever picks a case —
/// it never builds UI text or talks to Toasty itself.
enum AuthenticationFeedback: Equatable {

    case error(AuthenticationError)
    case accountCreated
    case signedIn
    case continuedAsDemo
    case passwordResetSent

    /// Presents this feedback as a toast.
    /// - Parameter toasty: The shared toast notification manager.
    func present(with toasty: ToastyManager) {
        switch self {
        case .error(let error):
            toasty.showError(error)
        case .accountCreated:
            toasty.showSuccess(String(localized: .authFeedbackAccountCreated))
        case .signedIn:
            toasty.showSuccess(String(localized: .authFeedbackSignedIn))
        case .continuedAsDemo:
            toasty.showInfo(String(localized: .authFeedbackContinuedAsDemo))
        case .passwordResetSent:
            toasty.showSuccess(String(localized: .authFeedbackPasswordResetSent))
        }
    }
}
