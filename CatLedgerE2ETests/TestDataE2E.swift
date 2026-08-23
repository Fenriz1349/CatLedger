//
//  TestDataE2E.swift
//  CatLedgerE2ETests
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation
import FirebaseAuth

/// Shared setup for E2E tests running against the Firebase Local Emulator Suite.
/// Ports match `firebase.json`; start the emulators with `firebase emulators:start` before running.
enum TestDataE2E {

    static let authEmulatorPort = 9099

    /// Points Firebase Auth at the local emulator. Safe to call multiple times: only the first
    /// call has an effect, later ones are no-ops guarded by this same static initializer.
    static let connectAuthToEmulator: Void = {
        Auth.auth().useEmulator(withHost: "localhost", port: authEmulatorPort)
    }()

    /// Returns a unique email address, so repeated test runs never collide on an existing account.
    static func uniqueEmail() -> String {
        "e2e-\(UUID().uuidString)@catledger.test"
    }
}
