//
//  HomeView.swift
//  Neura
//
//  Created by Fırat İlhan on 8.11.2026.
//


import SwiftUI


struct ChatView: View {
    @State private var mesaj = ""
    @State private var sonuc = "Mesaj yok"
    @FocusState private var klavyeAcik:Bool
    @State private var mesajlar: [String] = []
    
    var body: some View {
        
        ZStack {
            VStack(spacing: 15) {
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(mesajlar.indices, id: \.self) { index in
                                Text(mesajlar[index])
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }

                        }
                        .padding()
                        .frame(
                            maxWidth: .infinity,
                            minHeight: geometry.size.height,
                            alignment: .bottom
                        )
                    }
                }
                
                HStack(spacing: 10) {
                    
                    TextField("Mesajınızı yazın...", text: $mesaj, axis: .vertical)
                        .lineLimit(1...4)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .focused($klavyeAcik)
                    
                    Button {
                        let yeniMesaj = mesaj.trimmingCharacters(in: .whitespacesAndNewlines)

                        if !yeniMesaj.isEmpty {
                            mesajlar.append(yeniMesaj)
                            mesaj = ""
                        }
                        klavyeAcik = false
                    } label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 46, height: 46)
                            .background(Color.blue.gradient)
                            .clipShape(Circle())
                    }
                    .disabled(mesaj.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding()
            
        }
        .contentShape(Rectangle())
        .onTapGesture {
            klavyeAcik = false
        }
    }
}
