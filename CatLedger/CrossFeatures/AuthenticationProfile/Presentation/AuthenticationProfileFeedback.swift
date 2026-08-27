//
//  AuthenticationProfileFeedback.swift
//  CatLedger
//
//  Created by Julien Cotte on 27/08/2026.
//

import Foundation
import Toasty

/// Every user-facing outcome the Authentication/Profile cross-feature actions can produce.
/// Owns the toast text and style for each case, so the ViewModel only ever picks a case —
/// it never builds UI text or talks to Toasty itself.
enum AuthenticationProfileFeedback: Equatable {

    case authenticationError(AuthenticationError)
    case profileError(ProfileError)
    case accountCreated
    case continuedAsDemo

    /// Presents this feedback as a toast.
    /// - Parameter toasty: The shared toast notification manager.
    func present(with toasty: ToastyManager) {
        switch self {
        case .authenticationError(let error):
            toasty.showError(error)
        case .profileError(let error):
            toasty.showError(error)
        case .accountCreated:
            toasty.showSuccess(String(localized: .authProfileFeedbackAccountCreated))
        case .continuedAsDemo:
            toasty.showInfo(String(localized: .authProfileFeedbackContinuedAsDemo))
        }
    }
}
