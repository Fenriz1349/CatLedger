//
//  AppContainer.swift
//  CatLedger
//
//  Created by Julien Cotte on 27/08/2026.
//

import Foundation

/// Root composition of the app: holds one container per feature (or cross-feature pairing).
/// Holds no business logic and no view model factories of its own — every factory lives on
/// whichever container already owns all of that view model's dependencies.
final class AppContainer {

    let authentication: AuthenticationContainer
    let profile: ProfileContainer
    let authenticationProfile: AuthenticationProfileContainer
    let networkMonitor: NetworkMonitor

    init() {
        authentication = AuthenticationContainer()
        profile = ProfileContainer()
        authenticationProfile = AuthenticationProfileContainer(
            authentication: authentication,
            profile: profile
        )
        networkMonitor = NetworkMonitor()
    }
}
