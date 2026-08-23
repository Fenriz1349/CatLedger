//
//  FirebaseProfileSource.swift
//  CatLedger
//
//  Created by Julien Cotte on 23/08/2026.
//

import Foundation
import FirebaseFirestore

/// Thin wrapper around the `profiles` Firestore collection. Holds no business logic, only raw
/// reads and writes — encoding/decoding and error mapping are the responsibility of the caller.
final class FirebaseProfileSource {

    private var collection: CollectionReference { Firestore.firestore().collection("profiles") }

    /// Fetches the first document whose `registrationId` field matches the given value.
    /// - Returns: The raw document data, or nil if none matches.
    func fetch(byRegistrationId registrationId: String) async throws -> [String: Any]? {
        let snapshot = try await collection
            .whereField("registrationId", isEqualTo: registrationId)
            .limit(to: 1)
            .getDocuments()
        return snapshot.documents.first?.data()
    }

    /// Writes the full document, replacing any existing data at that id.
    func save(id: String, data: [String: Any]) async throws {
        try await collection.document(id).setData(data)
    }

    /// Merges the given fields into the existing document at that id.
    func update(id: String, data: [String: Any]) async throws {
        try await collection.document(id).setData(data, merge: true)
    }

    /// Deletes the document at that id.
    func delete(id: String) async throws {
        try await collection.document(id).delete()
    }
}
