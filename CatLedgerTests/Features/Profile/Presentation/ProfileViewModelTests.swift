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

    private func makeViewModel(context: ProfileViewModel.Context) -> ProfileViewModel {
        ProfileViewModel(
            context: context,
            createProfile: CreateProfile(repository: repository),
            updateProfile: UpdateProfile(repository: repository)
        )
    }

    // MARK: create context

    @Test("Starts with empty fields when creating a new profile")
    func init_createContext_startsWithEmptyFields() {
        let viewModel = makeViewModel(context: .create(registrationId: UUID()))
        #expect(viewModel.firstName.isEmpty)
        #expect(viewModel.lastName.isEmpty)
    }

    @Test("Submitting valid names persists the new profile and reports no feedback")
    func submit_createContext_validNames_reportsNoFeedback() async throws {
        let registrationId = UUID()
        let viewModel = makeViewModel(context: .create(registrationId: registrationId))
        viewModel.firstName = TestData.firstName
        viewModel.lastName = TestData.lastName

        await viewModel.submit()

        #expect(viewModel.feedback == nil)
        let created = try await repository.fetch(by: registrationId)
        #expect(created.firstName == TestData.firstName)
        #expect(created.lastName == TestData.lastName)
    }

    @Test("A non-ProfileError repository failure falls back to creationFailed")
    func submit_createContext_repositoryThrowsGenericError_fallsBackToCreationFailed() async {
        let viewModel = makeViewModel(context: .create(registrationId: UUID()))
        viewModel.firstName = TestData.firstName
        viewModel.lastName = TestData.lastName
        repository.errorToThrow = GenericError()

        await viewModel.submit()

        #expect(viewModel.feedback == .error(.creationFailed))
    }

    // MARK: existing context

    @Test("Pre-fills the form with the profile's current name")
    func init_existingContext_prefillsNameFromProfile() {
        let profile = TestData.profile()
        let viewModel = makeViewModel(context: .existing(profile))
        #expect(viewModel.firstName == profile.firstName)
        #expect(viewModel.lastName == profile.lastName)
    }

    @Test("isFormValid is false when a name field is empty")
    func isFormValid_emptyFirstName_returnsFalse() {
        let viewModel = makeViewModel(context: .existing(TestData.profile()))
        viewModel.firstName = ""
        #expect(!viewModel.isFormValid)
    }

    @Test("Submitting valid names persists the update, reports no feedback, and exits edit mode")
    func submit_existingContext_validNames_reportsNoFeedbackAndExitsEditMode() async throws {
        let profile = TestData.profile()
        try await repository.save(profile)
        let viewModel = makeViewModel(context: .existing(profile))
        viewModel.isEditing = true
        let newName = TestData.updateProfileInput()
        viewModel.firstName = newName.firstName
        viewModel.lastName = newName.lastName

        await viewModel.submit()

        #expect(viewModel.feedback == nil)
        #expect(!viewModel.isEditing)
        let updated = try await repository.fetch(by: profile.registrationId)
        #expect(updated.firstName == newName.firstName)
    }

    @Test("An invalid form is not submitted and reports no feedback")
    func submit_existingContext_invalidForm_reportsNoFeedback() async {
        let viewModel = makeViewModel(context: .existing(TestData.profile()))
        viewModel.firstName = ""
        await viewModel.submit()
        #expect(viewModel.feedback == nil)
        #expect(viewModel.firstNameState == .invalid)
    }

    @Test("A repository error is reported as error feedback and edit mode stays open")
    func submit_existingContext_repositoryThrowsProfileError_reportsErrorAndStaysInEditMode() async {
        let viewModel = makeViewModel(context: .existing(TestData.profile()))
        viewModel.isEditing = true
        repository.errorToThrow = ProfileError.notFound
        await viewModel.submit()
        #expect(viewModel.feedback == .error(.notFound))
        #expect(viewModel.isEditing)
    }

    @Test("A non-ProfileError repository failure falls back to updateFailed")
    func submit_existingContext_repositoryThrowsGenericError_fallsBackToUpdateFailed() async {
        let viewModel = makeViewModel(context: .existing(TestData.profile()))
        repository.errorToThrow = GenericError()
        await viewModel.submit()
        #expect(viewModel.feedback == .error(.updateFailed))
    }
}
