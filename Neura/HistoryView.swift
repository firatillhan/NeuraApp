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
    @Environment(\.modelContext) private var modelContext
    @State private var duzenlenecekSohbet: Sohbet?
    @State private var yeniBaslik = ""
    
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
                .contextMenu {
                    Button {
                        yeniBaslik = sohbet.baslik
                        duzenlenecekSohbet = sohbet
                    } label: {
                        Label("Başlığı Düzenle", systemImage: "pencil")
                    }
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(sohbetler[index])
                }
                try? modelContext.save()

            }
        }
 
        .navigationTitle("Sohbet Geçmişi")
        .alert("Sohbet Başlığını Düzenle", isPresented: Binding(
            get: { duzenlenecekSohbet != nil },
            set: { if !$0 { duzenlenecekSohbet = nil } }
        )) {
            TextField("Yeni başlık", text: $yeniBaslik)

            Button("İptal", role: .cancel) {
                duzenlenecekSohbet = nil
            }

            Button("Kaydet") {
                if let sohbet = duzenlenecekSohbet {
                    let baslik = yeniBaslik.trimmingCharacters(in: .whitespacesAndNewlines)

                    if !baslik.isEmpty {
                        sohbet.baslik = baslik
                        try? modelContext.save()
                    }

                    duzenlenecekSohbet = nil
                }
            }
        } message: {
            Text("Sohbet için yeni bir başlık gir.")
        }
        
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

