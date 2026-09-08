//
//  ContentView.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import SwiftUI
import Toasty

/// The authenticated app shell: shown once a session and its profile are resolved. Only holds
/// `ProfileHandlingView` for now — the main screens and navigation land here once they exist.
struct ContentView: View {

    let profile: Profile
    let email: String?
    let appContainer: AppContainer
    let onSessionEnded: () async -> Void

    var body: some View {
        ProfileHandlingView(
            viewModel: appContainer.profile.makeViewModel(profile: profile),
            authenticationViewModel: appContainer.authentication.makeViewModel(
                context: .authenticated,
                onAuthenticated: { _ in },
                onLoggedOut: { await onSessionEnded() }
            ),
            authenticationProfileViewModel: appContainer.authenticationProfile.makeViewModel(
                onAuthenticated: { _ in },
                onSessionEnded: { await onSessionEnded() }
            ),
            registrationId: profile.registrationId,
            email: email
        )
    }
}

#Preview {
    let profile = Profile(registrationId: UUID(), displayName: "Bruce|Wayne")
    ContentView(profile: profile, email: "bruce@wayne.com", appContainer: AppContainer(), onSessionEnded: {})
        .environmentObject(ToastyManager())
}
