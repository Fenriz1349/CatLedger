//
//  CatLedgerApp.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import SwiftUI
import FirebaseCore
import Toasty

/// The app's entry point. Configures Firebase before the first scene is built.
@main
struct CatLedgerApp: App {
    @StateObject private var toasty: ToastyManager

    init() {
        let toasty = ToastyManager()
        FirebaseApp.configure()
        _toasty = StateObject(wrappedValue: toasty)
    }

    var body: some Scene {
        WindowGroup {
            ToastyContainer(manager: toasty) {
                ContentView()
                    .environmentObject(toasty)
            }
        }
    }
}
