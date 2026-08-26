//
//  ContentView.swift
//  CatLedger
//
//  Created by Julien Cotte on 21/08/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        AuthenticationView(viewModel: AuthenticationContainer().makeViewModel())
    }
}

#Preview {
    ContentView()
}
