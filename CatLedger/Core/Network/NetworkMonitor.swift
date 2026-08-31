//
//  NetworkMonitor.swift
//  CatLedger
//
//  Created by Julien Cotte on 31/08/2026.
//

import Foundation
import Network

/// Observes the device's network connectivity and can verify the backend is actually reachable
/// before an operation that requires it.
@MainActor
@Observable
final class NetworkMonitor {

    /// Whether the device currently has an active network interface. Use it for the offline
    /// screen and as a free first gate — not as proof the backend is reachable.
    private(set) var isConnected = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.catledger.networkmonitor")
    private let reachabilityURL = URL(string: "https://firestore.googleapis.com")!

    /// Starts the underlying `NWPathMonitor`, updating `isConnected` on the main actor as the
    /// interface status changes.
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            guard let self else { return }
            Task { @MainActor in self.isConnected = connected }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }

    /// Two-stage reachability gate: the cheap interface check, then a real round-trip to the
    /// backend. Call before any operation that requires network, so it never reaches Firestore
    /// while offline.
    /// - Throws: `OfflineError.notConnected` if the interface is down,
    /// `OfflineError.serverUnreachable` if the backend can't be reached.
    func verifyReachable() async throws {
        guard isConnected else { throw OfflineError.notConnected }
        guard await ping() else { throw OfflineError.serverUnreachable }
    }

    // MARK: Private

    /// Sends a short HEAD request to the backend. Any HTTP response means reachable; a thrown
    /// error (timeout, no route) means it isn't.
    private func ping() async -> Bool {
        var request = URLRequest(url: reachabilityURL)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 3
        // Always hit the network: a cached response would make us look reachable while offline.
        request.cachePolicy = .reloadIgnoringLocalCacheData
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            return response is HTTPURLResponse
        } catch {
            return false
        }
    }
}
