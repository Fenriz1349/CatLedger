//
//  AuthenticationView.swift
//  CatLedger
//
//  Created by Julien Cotte on 25/08/2026.
//

import SwiftUI
import Toasty

/// Sign-in / sign-up entry point, plus the anonymous demo shortcut.
/// UI is placeholder SwiftUI for now — branded components (header, buttons, background)
/// land once they're ported from EchoLedger.
struct AuthenticationView: View {

    @State var viewModel: AuthenticationViewModel
    @EnvironmentObject var toasty: ToastyManager

    var body: some View {
        VStack(spacing: 24) {

            Text("CatLedger")
                .font(.largeTitle.bold())
                .padding(.top, 40)

            Picker("", selection: $viewModel.isSignUp) {
                Text("Se connecter").tag(false)
                Text("Créer un compte").tag(true)
            }
            .pickerStyle(.segmented)

            AuthenticationFormContent(
                isSignUp: $viewModel.isSignUp,
                email: $viewModel.email,
                password: $viewModel.password,
                confirmPassword: $viewModel.confirmPassword,
                emailState: $viewModel.emailState,
                passwordState: $viewModel.passwordState,
                confirmPasswordState: $viewModel.confirmPasswordState,
                confirmPasswordValidator: viewModel.isValidConfirmPassword
            )

            // MARK: Password Reset
            if !viewModel.isSignUp {
                Button {
                    Task { await viewModel.forgotPassword() }
                } label: {
                    Text("Mot de passe oublié ?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .disabled(viewModel.isLoading)
            }

            // MARK: Submit
            Button {
                Task { await viewModel.submit() }
            } label: {
                Text(viewModel.isSignUp ? "Créer mon compte" : "Se connecter")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("button.authenticationSubmit")
            .disabled(!viewModel.isFormValid || viewModel.isLoading)

            Divider()

            // MARK: Demo Mode
            Button {
                Task { await viewModel.continueAnonymously() }
            } label: {
                Text("Continuer en mode démo")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .onChange(of: viewModel.feedback) { _, feedback in
            guard let feedback else { return }
            feedback.present(with: toasty)
        }
    }
}

#Preview {
    AuthenticationView(viewModel: AuthenticationContainer().makeViewModel())
        .environmentObject(ToastyManager())
}
