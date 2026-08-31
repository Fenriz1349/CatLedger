//
//  AppEntryView.swift
//  CatLedger
//
//  Created by Julien Cotte on 27/08/2026.
//

import SwiftUI
import Toasty

/// Chooses which screen to show at launch, based on whether a session (and its profile) exists.
struct AppEntryView: View {

    @State var viewModel: AppEntryViewModel
    let appContainer: AppContainer

    var body: some View {
        Group {
            switch viewModel.screen {
            case .none:
                ProgressView()
            case .authentication:
                RegistrationHandlingView(
                    authenticationViewModel: appContainer.authentication.makeViewModel(
                        context: .unauthenticated,
                        onAuthenticated: { _ in await viewModel.resolve() },
                        onLoggedOut: {}
                    ),
                    authenticationProfileViewModel: appContainer.authenticationProfile.makeViewModel(
                        onAuthenticated: { _ in await viewModel.resolve() },
                        onSessionEnded: {}
                    )
                )
            case .profile(let profile, let email):
                ProfileHandlingView(
                    viewModel: appContainer.profile.makeViewModel(profile: profile),
                    authenticationViewModel: appContainer.authentication.makeViewModel(
                        context: .authenticated,
                        onAuthenticated: { _ in },
                        onLoggedOut: { await viewModel.resolve() }
                    ),
                    authenticationProfileViewModel: appContainer.authenticationProfile.makeViewModel(
                        onAuthenticated: { _ in },
                        onSessionEnded: { await viewModel.resolve() }
                    ),
                    registrationId: profile.registrationId,
                    email: email
                )
            case .offline:
                OfflineView(onRetry: { Task { await viewModel.resolve() } })
            }
        }
        .task {
            await viewModel.resolve()
        }
        .onChange(of: appContainer.networkMonitor.isConnected) { _, connected in
            Task { await viewModel.connectivityChanged(isConnected: connected) }
        }
    }
}

#Preview {
    let appContainer = AppContainer()
    AppEntryView(
        viewModel: AppEntryViewModel(
            resolveSession: appContainer.authentication.resolveSession,
            getCurrentProfile: appContainer.profile.getCurrentProfile,
            verifyReachable: appContainer.networkMonitor.verifyReachable
        ),
        appContainer: appContainer
    )
    .environmentObject(ToastyManager())
}
