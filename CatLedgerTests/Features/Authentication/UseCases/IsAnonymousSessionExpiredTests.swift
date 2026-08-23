//
//  IsAnonymousSessionExpiredTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct IsAnonymousSessionExpiredTests {

    private let repository = AuthenticationDouble()
    private let useCase: IsAnonymousSessionExpired

    init() {
        useCase = IsAnonymousSessionExpired(repository: repository)
    }

    @Test("Returns true when the session has exceeded its validity period")
    func execute_expiredSession_returnsTrue() {
        repository.isExpired = true
        #expect(useCase.execute())
    }

    @Test("Returns false when the session is still valid")
    func execute_validSession_returnsFalse() {
        repository.isExpired = false
        #expect(!useCase.execute())
    }
}
