//
//  HomeView.swift
//  Neura
//
//  Created by Fırat İlhan on 8.11.2026.
//


import SwiftUI
import FoundationModels
import AVFoundation
import SwiftData

struct ChatView: View {
    let sohbet: Sohbet?
    
    @State private var kullaniciYazi = ""
    @State private var sonuc = "Mesaj yok"
    @FocusState private var klavyeAcik:Bool
    @Environment(\.modelContext) private var modelContext
    @Query private var sohbetler: [Sohbet]
    
    @State private var yukleniyor = false
    @State private var konusmaMotoru = AVSpeechSynthesizer()
    
    @State private var aktifSohbet: Sohbet? = nil
    @State private var mesajlar: [Mesaj] = []

    var body: some View {
        ZStack {
            
            VStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Neura.")
                        .font(.largeTitle.bold())
                    
                    Text("Ask anything.")
                        .font(.title2)
                    
                    Text("A little curious, a little sarcastic. Always ready to help.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 12)
                
                
                
                
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(mesajlar.indices, id: \.self) { index in
                                let mesaj = mesajlar[index]

                                VStack(alignment: mesaj.kullaniciMi ? .trailing : .leading, spacing: 5) {
                                    Text(mesaj.icerik)
                                        .textSelection(.enabled)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(mesaj.kullaniciMi ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundStyle(mesaj.kullaniciMi ? .white : .primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))

                                    if !mesaj.kullaniciMi {
                                        Button {
                                            seslendir(mesaj.icerik)
                                        } label: {
                                            Image(systemName: "speaker.wave.2")
                                                .font(.system(size: 15))
                                                .foregroundStyle(.secondary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: mesaj.kullaniciMi ? .trailing : .leading
                                )
                            }
                            if yukleniyor {
                                HStack {
                                    ProgressView()
                                        .padding(12)
                                        .background(Color.gray.opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    Spacer()
                                }
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
                    TextField("Text your message...", text: $kullaniciYazi, axis: .vertical)
                        .lineLimit(1...4)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .focused($klavyeAcik)
                    
                    Button {
                        let mesaj = kullaniciYazi.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !mesaj.isEmpty else { return }

                        // İlk mesajsa yeni sohbet oluştur
                        if aktifSohbet == nil {
                            let yeniSohbet = Sohbet(baslik: mesaj)
                            modelContext.insert(yeniSohbet)
                            aktifSohbet = yeniSohbet
                        }

                        // Kullanıcı mesajını kaydet
                        let kullaniciMesaji = Mesaj(icerik: mesaj, kullaniciMi: true)
                        aktifSohbet?.mesajlar.append(kullaniciMesaji)
                        mesajlar.append(kullaniciMesaji)

                        Task {
                            yukleniyor = true
                            kullaniciYazi = ""

                            do {
                                sonuc = try await modeliTestEt(mesaj)

                                let aiMesaji = Mesaj(icerik: sonuc, kullaniciMi: false)
                                aktifSohbet?.mesajlar.append(aiMesaji)
                                mesajlar.append(aiMesaji)

                                try modelContext.save()

                            } catch {
                                print("Hata: \(error)")
                            }

                            yukleniyor = false
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
                    .disabled(kullaniciYazi.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .disabled(sohbet != nil)
                
                
                
                
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(Color.indigo.opacity(0.15), for: .navigation)
        .contentShape(Rectangle())
        .onTapGesture {
            klavyeAcik = false
        }
        .onAppear {
            if let sohbet {
                aktifSohbet = sohbet
                mesajlar = sohbet.mesajlar
            }
        }
    }
    
    func modeliTestEt(_ yazi: String) async throws -> String {

        let oturum2 = LanguageModelSession(instructions: """
        You are an English speaking practice evaluator.
        The user's native language is Turkish.

        Evaluate English sentences as everyday spoken English.

        Rules:
        - Focus on meaning, understandability and naturalness.
        - Ignore grammar, spelling, capitalization and punctuation.
        - Do not penalize grammar mistakes if the meaning is clear.
        - Accept informal conversational English.
        - Give all feedback in Turkish.
        - Keep feedback short and encouraging.
        - Score consistently with your evaluation.
        - Never rewrite, correct, translate or suggest alternatives.
        - Evaluate only the sentence provided by the user.

        Scoring:
        - 90-100: Clear and natural.
        - 80-89: Understandable with minor awkwardness.
        - 60-79: Understandable but unnatural.
        - 40-59: Partially understandable.
        - 0-39: Difficult to understand.

        Return exactly:

        Score: [0-100]
        Understandability: [Turkish explanation]
        Naturalness: [Turkish explanation]
        """)


        
        let sonuc2 = try await oturum2.respond(to: yazi)
        return sonuc2.content
    }
    private func seslendir(_ metin: String) {
        konusmaMotoru.stopSpeaking(at: .immediate)

        let konusma = AVSpeechUtterance(string: metin)
        konusma.voice = AVSpeechSynthesisVoice(language: "en-US")
        konusma.rate = 0.48

        konusmaMotoru.speak(konusma)
    }
    
    
}



