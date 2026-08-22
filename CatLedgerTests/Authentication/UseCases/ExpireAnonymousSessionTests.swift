//
//  ExpireAnonymousSessionTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct ExpireAnonymousSessionTests {

    private let repository = AuthenticationDouble()
    private let useCase: ExpireAnonymousSession

    init() {
        useCase = ExpireAnonymousSession(repository: repository)
    }

    @Test("Expires and returns true when the session has exceeded its validity period")
    func execute_expiredSession_expiresAndReturnsTrue() async {
        repository.isExpired = true
        let result = await useCase.execute()
        #expect(result)
        #expect(repository.didCallExpire)
    }

    @Test("Does nothing and returns false when the session is still valid")
    func execute_validSession_returnsFalse() async {
        repository.isExpired = false
        let result = await useCase.execute()
        #expect(!result)
        #expect(!repository.didCallExpire)
    }
}
