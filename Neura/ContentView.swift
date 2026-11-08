//
//  ContentView.swift
//  Neura
//
//  Created by Fırat İlhan on 8.11.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            TabView {
                HomeView()
                    .tabItem { Label("", systemImage: "house") }
                TestView()
                    .tabItem { Label("", systemImage: "gear") }

            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
