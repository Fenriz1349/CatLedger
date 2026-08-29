//
//  ProfileFeedbackTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 27/08/2026.
//

import Foundation
import Testing
import Toasty
@testable import CatLedger

@MainActor
struct ProfileFeedbackTests {

    private let toasty = ToastyManager()

    @Test("Presents an error toast for a wrapped ProfileError")
    func present_error_showsErrorToast() {
        ProfileFeedback.error(.notFound).present(with: toasty)
        #expect(toasty.currentToast?.type == .error)
    }

}
