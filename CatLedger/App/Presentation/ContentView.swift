//
//  ContentView.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import SwiftUI
import Toasty

struct ContentView: View {

    let appContainer: AppContainer

    var body: some View {
        AppEntryView(
            viewModel: AppEntryViewModel(
                resolveSession: appContainer.authentication.resolveSession,
                getCurrentProfile: appContainer.profile.getCurrentProfile
            ),
            appContainer: appContainer
        )
    }
}

#Preview {
    ContentView(appContainer: AppContainer())
        .environmentObject(ToastyManager())
}
