//
//  AuthenticationFeedbackTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 26/08/2026.
//

import Foundation
import Testing
import Toasty
@testable import CatLedger

@MainActor
struct AuthenticationFeedbackTests {

    private let toasty = ToastyManager()

    @Test("Presents an error toast for a wrapped AuthenticationError")
    func present_error_showsErrorToast() {
        AuthenticationFeedback.error(.logInFailed).present(with: toasty)
        #expect(toasty.currentToast?.type == .error)
    }

    @Test("Presents a success toast when a password reset email is sent")
    func present_passwordResetSent_showsSuccessToast() {
        AuthenticationFeedback.passwordResetSent.present(with: toasty)
        #expect(toasty.currentToast?.type == .success)
    }
}
