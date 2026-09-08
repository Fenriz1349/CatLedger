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
                    authenticationViewModel: viewModel.makeAuthenticationViewModel(),
                    authenticationProfileViewModel: viewModel.makeAuthenticationProfileViewModel()
                )
            case .profile(let profile, let email):
                ContentView(
                    profile: profile,
                    email: email,
                    appContainer: appContainer,
                    onSessionEnded: { await viewModel.resolve() }
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
            verifyReachable: appContainer.networkMonitor.verifyReachable,
            authenticationContainer: appContainer.authentication,
            authenticationProfileContainer: appContainer.authenticationProfile
        ),
        appContainer: appContainer
    )
    .environmentObject(ToastyManager())
}
