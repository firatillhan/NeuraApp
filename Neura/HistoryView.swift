//
//  HistoryView.swift
//  Neura
//
//  Created by Fırat İlhan on 10.11.2026.
//


import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \Sohbet.olusturmaTarihi, order: .reverse)
    private var sohbetler: [Sohbet]

    var body: some View {
        List {
            ForEach(sohbetler) { sohbet in
                NavigationLink {
                    ChatView(sohbet: sohbet)
                        .toolbar(.hidden, for: .tabBar)
                } label: {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(sohbet.baslik)
                            .font(.headline)
                            .lineLimit(1)

                        Text(sohbet.olusturmaTarihi, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Sohbet Geçmişi")
        .overlay {
            if sohbetler.isEmpty {
                ContentUnavailableView(
                    "Henüz sohbet yok",
                    systemImage: "bubble.left.and.bubble.right",
                    description: Text("Yaptığın sohbetler burada görünecek.")
                )
            }
        }
    }
}

