//
//  ProfileViewModelTests.swift
//  CatLedgerTests
//
//  Created by Julien Cotte on 27/08/2026.
//

import Foundation
import Testing
import CustomTextFields
@testable import CatLedger

@MainActor
struct ProfileViewModelTests {

    private struct GenericError: Error {}

    private let repository = ProfileDouble()
    private let profile: Profile
    private let viewModel: ProfileViewModel

    init() {
        profile = TestData.profile()
        viewModel = ProfileViewModel(profile: profile, updateProfile: UpdateProfile(repository: repository))
    }

    @Test("Pre-fills the form with the profile's current name")
    func init_prefillsNameFromProfile() {
        #expect(viewModel.firstName == profile.firstName)
        #expect(viewModel.lastName == profile.lastName)
    }

    @Test("isFormValid is false when a name field is empty")
    func isFormValid_emptyFirstName_returnsFalse() {
        viewModel.firstName = ""
        #expect(!viewModel.isFormValid)
    }

    @Test("Submitting valid names persists the update and reports profileUpdated")
    func submit_validNames_reportsProfileUpdated() async throws {
        try await repository.save(profile)
        let newName = TestData.updateProfileInput()
        viewModel.firstName = newName.firstName
        viewModel.lastName = newName.lastName
        await viewModel.submit()
        #expect(viewModel.feedback == .profileUpdated)
        let updated = try await repository.fetch(by: profile.registrationId)
        #expect(updated.firstName == newName.firstName)
    }

    @Test("An invalid form is not submitted and reports no feedback")
    func submit_invalidForm_reportsNoFeedback() async {
        viewModel.firstName = ""
        await viewModel.submit()
        #expect(viewModel.feedback == nil)
        #expect(viewModel.firstNameState == .invalid)
    }

    @Test("A repository error is reported as error feedback")
    func submit_repositoryThrowsProfileError_reportsError() async {
        repository.errorToThrow = ProfileError.notFound
        await viewModel.submit()
        #expect(viewModel.feedback == .error(.notFound))
    }

    @Test("A non-ProfileError repository failure falls back to updateFailed")
    func submit_repositoryThrowsGenericError_fallsBackToUpdateFailed() async {
        repository.errorToThrow = GenericError()
        await viewModel.submit()
        #expect(viewModel.feedback == .error(.updateFailed))
    }
}
