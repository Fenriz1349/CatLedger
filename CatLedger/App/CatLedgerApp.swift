//
//  CatLedgerApp.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import SwiftUI
import FirebaseCore

/// The app's entry point. Configures Firebase before the first scene is built.
@main
struct CatLedgerApp: App {

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
