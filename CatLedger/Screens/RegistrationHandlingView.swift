//
//  RegistrationHandlingView.swift
//  CatLedger
//
//  Created by Julien Cotte on 25/08/2026.
//

import SwiftUI
import Toasty

/// Log-in / sign-up entry point, plus the anonymous demo shortcut.
/// Logging in stays purely Authentication; signing up and the demo shortcut both also create a
/// profile, so they go through the cross-feature `AuthenticationProfileViewModel` instead.
/// UI is placeholder SwiftUI for now — branded components (header, buttons, background)
/// land once they're ported from EchoLedger.
struct RegistrationHandlingView: View {

    @State var authenticationViewModel: AuthenticationViewModel
    @State var authenticationProfileViewModel: AuthenticationProfileViewModel
    @EnvironmentObject var toasty: ToastyManager

    var body: some View {
        VStack(spacing: 24) {

            Text("CatLedger")
                .font(.largeTitle.bold())
                .padding(.top, 40)

            Picker("", selection: $authenticationViewModel.isSigningUp) {
                Text("Se connecter").tag(false)
                Text("Créer un compte").tag(true)
            }
            .pickerStyle(.segmented)

            if authenticationViewModel.isSigningUp {
                ProfileFormContent(
                    firstName: $authenticationProfileViewModel.firstName,
                    lastName: $authenticationProfileViewModel.lastName,
                    firstNameState: $authenticationProfileViewModel.firstNameState,
                    lastNameState: $authenticationProfileViewModel.lastNameState,
                    firstNameValidator: authenticationProfileViewModel.isValidName,
                    lastNameValidator: authenticationProfileViewModel.isValidName
                )
            }

            AuthenticationFormContent(
                isSigningUp: $authenticationViewModel.isSigningUp,
                email: $authenticationViewModel.email,
                password: $authenticationViewModel.password,
                confirmPassword: $authenticationViewModel.confirmPassword,
                emailState: $authenticationViewModel.emailState,
                passwordState: $authenticationViewModel.passwordState,
                confirmPasswordState: $authenticationViewModel.confirmPasswordState,
                confirmPasswordValidator: authenticationViewModel.isValidConfirmPassword
            )

            // MARK: Password Reset
            if !authenticationViewModel.isSigningUp {
                Button {
                    Task { await authenticationViewModel.forgottenPassword() }
                } label: {
                    Text("Mot de passe oublié ?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .disabled(authenticationViewModel.isLoading)
            }

            // MARK: Submit
            if authenticationViewModel.isSigningUp {
                Button {
                    Task {
                        await authenticationProfileViewModel.signUp(
                            email: authenticationViewModel.email,
                            password: authenticationViewModel.password
                        )
                    }
                } label: {
                    Text("Créer mon compte")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("button.registrationSubmit")
                .disabled(
                    !authenticationViewModel.isFormValid
                        || !authenticationProfileViewModel.isProfileFormValid
                        || authenticationProfileViewModel.isLoading
                )
            } else {
                Button {
                    Task { await authenticationViewModel.logIn() }
                } label: {
                    Text("Se connecter")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("button.registrationSubmit")
                .disabled(!authenticationViewModel.isFormValid || authenticationViewModel.isLoading)
            }

            Divider()

            // MARK: Demo Mode
            Button {
                Task { await authenticationProfileViewModel.continueAsDemo() }
            } label: {
                Text("Continuer en mode démo")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(authenticationProfileViewModel.isLoading)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .overlay {
            if authenticationViewModel.isLoading || authenticationProfileViewModel.isLoading {
                ProgressView()
            }
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
    let authenticationContainer = AuthenticationContainer()
    let profileContainer = ProfileContainer()
    RegistrationHandlingView(
        authenticationViewModel: authenticationContainer.makeViewModel(onAuthenticated: { _ in }),
        authenticationProfileViewModel: AuthenticationProfileContainer(
            authentication: authenticationContainer,
            profile: profileContainer
        ).makeViewModel(onAuthenticated: { _ in })
    )
    .environmentObject(ToastyManager())
}
