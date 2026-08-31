//
//  OfflineView.swift
//  CatLedger
//
//  Created by Julien Cotte on 31/08/2026.
//

import SwiftUI

/// Shown when the app can't reach the backend at launch, in place of the authentication or
/// profile screen. Purely presentational — the caller decides what retrying actually means.
/// UI is placeholder SwiftUI for now — branded components (header, buttons, background)
/// land once they're ported from EchoLedger.
struct OfflineView: View {

    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text(.offlineViewMessage)
                .font(.subheadline)
                .multilineTextAlignment(.center)

            Button {
                onRetry()
            } label: {
                Text(.offlineViewRetryButton)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    OfflineView(onRetry: {})
}
