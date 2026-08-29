//
//  ProfileHandlingView.swift
//  CatLedger
//
//  Created by Julien Cotte on 25/08/2026.
//

import SwiftUI
import Toasty

/// Profile screen: displays the current name (with an edit form), the registration's email or
/// demo status, and the log-out / delete-account actions.
/// UI is placeholder SwiftUI for now — branded components (header, buttons, background)
/// land once they're ported from EchoLedger.
struct ProfileHandlingView: View {

    @State var viewModel: ProfileViewModel
    @State var authenticationViewModel: AuthenticationViewModel
    @State var authenticationProfileViewModel: AuthenticationProfileViewModel
    let registrationId: UUID
    let email: String?
    @EnvironmentObject var toasty: ToastyManager
    @State private var isConfirmingDeletion = false

    var body: some View {
        VStack(spacing: 24) {

            Text(.profileHandlingTitle)
                .font(.largeTitle.bold())
                .padding(.top, 40)

            Text(email ?? String(localized: .profileHandlingDemoModeLabel))
                .font(.subheadline)
                .foregroundColor(.secondary)

            if viewModel.isEditing {
                ProfileFormContent(
                    firstName: $viewModel.firstName,
                    lastName: $viewModel.lastName,
                    firstNameState: $viewModel.firstNameState,
                    lastNameState: $viewModel.lastNameState,
                    firstNameValidator: viewModel.isValidName,
                    lastNameValidator: viewModel.isValidName
                )

                Button {
                    Task { await viewModel.submit() }
                } label: {
                    Text(.profileHandlingSaveButton)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("button.profileSubmit")
                .disabled(!viewModel.isFormValid || viewModel.isLoading)
            } else {
                Text(verbatim: "\(viewModel.firstName) \(viewModel.lastName)")
                    .font(.title2)

                Button(String(localized: .profileHandlingEditButton)) {
                    viewModel.isEditing = true
                }
                .buttonStyle(.bordered)
            }

            Divider()

            Button {
                Task { await authenticationViewModel.logOut() }
            } label: {
                Text(.profileHandlingLogOutButton)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(authenticationViewModel.isLoading)

            Button(role: .destructive) {
                isConfirmingDeletion = true
            } label: {
                Text(.profileHandlingDeleteButton)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(authenticationProfileViewModel.isLoading)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .overlay {
            if viewModel.isLoading || authenticationViewModel.isLoading || authenticationProfileViewModel.isLoading {
                ProgressView()
            }
        }
        .confirmationDialog(
            Text(.profileHandlingDeleteConfirmationTitle),
            isPresented: $isConfirmingDeletion,
            titleVisibility: .visible
        ) {
            Button(String(localized: .profileHandlingDeleteConfirmButton), role: .destructive) {
                Task { await authenticationProfileViewModel.deleteFirebaseRegistration(registrationId: registrationId) }
            }
            Button(String(localized: .profileHandlingCancelButton), role: .cancel) {}
        }
        .onChange(of: viewModel.feedback) { _, feedback in
            guard let feedback else { return }
            feedback.present(with: toasty)
        }
        .onChange(of: authenticationViewModel.feedback) { _, feedback in
            guard let feedback else { return }
            feedback.present(with: toasty)
        }
        .onChange(of: authenticationProfileViewModel.feedback) { _, feedback in
            guard let feedback else { return }
            feedback.present(with: toasty)
        }
    }
}

#Preview {
    let profile = Profile(registrationId: UUID(), displayName: "Bruce|Wayne")
    let authenticationContainer = AuthenticationContainer()
    let profileContainer = ProfileContainer()
    ProfileHandlingView(
        viewModel: profileContainer.makeViewModel(profile: profile),
        authenticationViewModel: authenticationContainer.makeViewModel(
            context: .authenticated,
            onAuthenticated: { _ in },
            onLoggedOut: {}
        ),
        authenticationProfileViewModel: AuthenticationProfileContainer(
            authentication: authenticationContainer,
            profile: profileContainer
        ).makeViewModel(onAuthenticated: { _ in }, onSessionEnded: {}),
        registrationId: profile.registrationId,
        email: "bruce@wayne.com"
    )
    .environmentObject(ToastyManager())
}
