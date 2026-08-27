//
//  ProfileView.swift
//  CatLedger
//
//  Created by Julien Cotte on 25/08/2026.
//

import SwiftUI
import Toasty

/// Profile editing screen (first and last name).
/// UI is placeholder SwiftUI for now — branded components (header, buttons, background)
/// land once they're ported from EchoLedger.
struct ProfileView: View {

    @State var viewModel: ProfileViewModel
    @EnvironmentObject var toasty: ToastyManager

    var body: some View {
        VStack(spacing: 24) {

            Text("Mon profil")
                .font(.largeTitle.bold())
                .padding(.top, 40)

            ProfileFormContent(
                firstName: $viewModel.firstName,
                lastName: $viewModel.lastName,
                firstNameState: $viewModel.firstNameState,
                lastNameState: $viewModel.lastNameState,
                firstNameValidator: viewModel.isValidName,
                lastNameValidator: viewModel.isValidName
            )

            // MARK: Submit
            Button {
                Task { await viewModel.submit() }
            } label: {
                Text("Enregistrer")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("button.profileSubmit")
            .disabled(!viewModel.isFormValid || viewModel.isLoading)
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
    let profile = Profile(registrationId: UUID(), displayName: "Bruce|Wayne")
    ProfileView(viewModel: ProfileContainer().makeViewModel(profile: profile))
        .environmentObject(ToastyManager())
}
