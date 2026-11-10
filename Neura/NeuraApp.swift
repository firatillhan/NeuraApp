//
//  NeuraApp.swift
//  Neura
//
//  Created by Fırat İlhan on 8.11.2026.
//

import SwiftUI
import SwiftData

@main
struct NeuraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Sohbet.self, Mesaj.self])
    }
}
