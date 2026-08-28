//
//  AuthenticationProfileFeedbackTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 27/08/2026.
//

import Foundation
import Testing
import Toasty
@testable import CatLedger

@MainActor
struct AuthenticationProfileFeedbackTests {

    private let toasty = ToastyManager()

    @Test("Presents an error toast for a wrapped AuthenticationError")
    func present_authenticationError_showsErrorToast() {
        AuthenticationProfileFeedback.authenticationError(.logInFailed).present(with: toasty)
        #expect(toasty.currentToast?.type == .error)
    }

    @Test("Presents an error toast for a wrapped ProfileError")
    func present_profileError_showsErrorToast() {
        AuthenticationProfileFeedback.profileError(.notFound).present(with: toasty)
        #expect(toasty.currentToast?.type == .error)
    }

    @Test("Presents a success toast when signed up")
    func present_signedUp_showsSuccessToast() {
        AuthenticationProfileFeedback.signedUp.present(with: toasty)
        #expect(toasty.currentToast?.type == .success)
    }

    @Test("Presents an info toast when continuing as demo")
    func present_continuedAsDemo_showsInfoToast() {
        AuthenticationProfileFeedback.continuedAsDemo.present(with: toasty)
        #expect(toasty.currentToast?.type == .info)
    }
}
