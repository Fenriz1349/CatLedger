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
                AuthenticationView(viewModel: appContainer.authentication.makeViewModel())
            case .profile(let profile, _):
                ProfileView(viewModel: appContainer.profile.makeViewModel(profile: profile))
            }
        }
        .task {
            await viewModel.resolve()
        }
    }
}

#Preview {
    let appContainer = AppContainer()
    AppEntryView(
        viewModel: AppEntryViewModel(
            resolveSession: appContainer.authentication.resolveSession,
            getCurrentProfile: appContainer.profile.getCurrentProfile
        ),
        appContainer: appContainer
    )
    .environmentObject(ToastyManager())
}
