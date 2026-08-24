//
//  TestHelperE2E.swift
//  CatLedgerE2ETests
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Shared setup for E2E tests running against the Firebase Local Emulator Suite.
/// Ports match `firebase.json`; start the emulators with `firebase emulators:start` before running.
enum TestHelperE2E {

    static let authEmulatorPort = 9099
    static let firestoreEmulatorPort = 8080

    /// Points Firebase Auth at the local emulator. Safe to call multiple times: only the first
    /// call has an effect, later ones are no-ops guarded by this same static initializer.
    static let connectAuthToEmulator: Void = {
        Auth.auth().useEmulator(withHost: "localhost", port: authEmulatorPort)
    }()

    /// Points Firestore at the local emulator. Safe to call multiple times: only the first call
    /// has an effect, later ones are no-ops guarded by this same static initializer.
    /// Configured explicitly (rather than via `useEmulator`) because the emulator serves plain
    /// HTTP: settings must have SSL off and persistence off, or writes hang trying to negotiate TLS.
    static let connectFirestoreToEmulator: Void = {
        let settings = Firestore.firestore().settings
        settings.host = "localhost:\(firestoreEmulatorPort)"
        settings.isSSLEnabled = false
        settings.isPersistenceEnabled = false
        Firestore.firestore().settings = settings
    }()

    /// Returns a unique email address, so repeated test runs never collide on an existing account.
    static func uniqueEmail() -> String {
        "e2e-\(UUID().uuidString)@catledger.test"
    }
}
