//
//  FirebaseTransactionSource.swift
//  CatLedger
//
//  Created by Julien Cotte on 24/08/2026.
//

import Foundation
import FirebaseFirestore

/// Thin wrapper around the `transactions` Firestore collection. Holds no business logic, only
/// raw reads and writes — encoding/decoding and error mapping are the responsibility of the caller.
final class FirebaseTransactionSource {

    private var collection: CollectionReference { Firestore.firestore().collection("transactions") }

    /// Fetches the raw document data at the given id.
    /// - Returns: The document data, or nil if no document exists at that id.
    func fetch(id: String) async throws -> [String: Any]? {
        try await collection.document(id).getDocument().data()
    }

    /// Fetches all documents whose `profileId` field matches the given value, ordered by date descending.
    func fetchAll(profileId: String) async throws -> [[String: Any]] {
        let snapshot = try await collection
            .whereField("profileId", isEqualTo: profileId)
            .order(by: "date", descending: true)
            .getDocuments()
        return snapshot.documents.map { $0.data() }
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
