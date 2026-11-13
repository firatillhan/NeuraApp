//
//  HomeView.swift
//  Neura
//
//  Created by Fırat İlhan on 8.11.2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink {
                    ChatView(sohbet: nil)
                        .toolbar(.hidden, for: .tabBar)
                } label: {
                    Text("Chat with Apple Intelligence")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                NavigationLink {
                    HistoryView()
                        .toolbar(.hidden, for: .tabBar)
                } label: {
                    Text("History View")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                NavigationLink {
                    ChatView(sohbet: nil, yazmaAlistirmasi: true)
                        .toolbar(.hidden, for: .tabBar)
                } label: {
                    Text("Writing Practice")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                
            }
            
            
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Neura")
    }
}


