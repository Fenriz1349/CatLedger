//
//  ResolveSessionTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 22/08/2026.
//

import Foundation
import Testing
@testable import CatLedger

struct ResolveSessionTests {

    private let repository = AuthenticationDouble()
    private let useCase: ResolveSession

    init() {
        useCase = ResolveSession(repository: repository)
    }

    @Test("Returns the stored session when one exists")
    func execute_storedSession_returnsSession() async {
        let session = AuthSession(profileId: UUID(), isAnonymous: false)
        repository.sessionToResolve = session
        let result = await useCase.execute()
        #expect(result?.profileId == session.profileId)
    }

    @Test("Returns nil when no session is stored")
    func execute_noStoredSession_returnsNil() async {
        let result = await useCase.execute()
        #expect(result == nil)
    }
}
