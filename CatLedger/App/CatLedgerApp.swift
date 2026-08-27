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
    @State private var appContainer: AppContainer

    init() {
        let toasty = ToastyManager()
        FirebaseApp.configure()
        _toasty = StateObject(wrappedValue: toasty)
        _appContainer = State(initialValue: AppContainer())
    }

    var body: some Scene {
        WindowGroup {
            ToastyContainer(manager: toasty) {
                ContentView(appContainer: appContainer)
                    .environmentObject(toasty)
            }
        }
    }
}
