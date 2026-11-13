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

    let yazmaAlistirmasi: Bool
    
    init(sohbet: Sohbet?, yazmaAlistirmasi: Bool = false) {
        self.sohbet = sohbet
        self.yazmaAlistirmasi = yazmaAlistirmasi
    }
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 15) {
                if mesajlar.isEmpty {
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
                }
                
                
                
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
                                HStack(spacing: 10) {
                                    ProgressView()
                                    Text("Neura is preparing a question...")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                    Spacer()
                                }
                                .padding(12)
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
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Write your answer...", text: $kullaniciYazi, axis: .vertical)
                            .lineLimit(1...6)

                        if yazmaAlistirmasi {
                            Text("\(kullaniciYazi.count) / 200 karakter")
                                .font(.caption)
                                .foregroundStyle(
                                    kullaniciYazi.count >= 200 ? .green : .secondary
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
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
                                if yazmaAlistirmasi {
                                    sonuc = try await yaziyiDegerlendir(mesaj)
                                } else {
                                    sonuc = try await modeliTestEt(mesaj)
                                }
                                
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
                    .disabled(
                        yazmaAlistirmasi
                        ? kullaniciYazi.trimmingCharacters(in: .whitespacesAndNewlines).count < 200
                        : kullaniciYazi.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
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
            } else if yazmaAlistirmasi {
                Task {
                    yukleniyor = true

                    do {
                        let soru = try await soruOlustur()

                        let yeniSohbet = Sohbet(baslik: "Writing Practice")
                        modelContext.insert(yeniSohbet)
                        aktifSohbet = yeniSohbet

                        let soruMesaji = Mesaj(
                            icerik: soru,
                            kullaniciMi: false
                        )

                        yeniSohbet.mesajlar.append(soruMesaji)
                        mesajlar.append(soruMesaji)

                        try modelContext.save()

                    } catch {
                        print("Soru oluşturma hatası: \(error)")
                    }

                    yukleniyor = false
                }
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
    
    func soruOlustur() async throws -> String {
        let konular = [
            "Travel and holidays",
            "Technology and artificial intelligence",
            "Daily routines",
            "Hobbies and free time",
            "Education and learning",
            "Friendship and relationships",
            "Future plans",
            "Life experiences",
            "Social media",
            "Food and culture",
            "Working life",
            "City life and nature"
        ]

        let secilenKonu = konular.randomElement()!

        let oturum = LanguageModelSession(instructions: """
        You are an English writing practice teacher.

        Generate exactly ONE short, interesting question in English.

        Rules:
        - Use only one sentence.
        - Maximum 20 words.
        - Ask an open-ended question.
        - Choose the given topic.
        - The answer should require at least 200 characters.
        - Do not add explanations or examples.
        - Return only the question.
        - Use simple everyday English (B1 level).
        - Maximum 12 words.
        - Avoid abstract, philosophical or academic questions.
        - Ask about familiar, real-life situations.
        - Use simple vocabulary.
        """)

        let cevap = try await oturum.respond(
            to: "Generate a new writing practice question about \(secilenKonu)."
        )

        return cevap.content
    }
    


    func yaziyiDegerlendir(_ yazi: String) async throws -> String {
        let oturum = LanguageModelSession(instructions: """
        You are a friendly and supportive English speaking coach.
        The user's native language is Turkish.

        Imagine the user is speaking English directly to another person
        in a real-life conversation.

        Evaluate the user's response as spoken conversational English,
        NOT as formal written English.

        IMPORTANT EVALUATION RULES:

        - Focus on communication, not grammatical perfection.
        - Ignore grammar mistakes.
        - Ignore capitalization.
        - Ignore punctuation.
        - Ignore spelling mistakes unless they make the meaning unclear.
        - Accept informal and everyday expressions.
        - Accept incomplete sentences if the meaning is clear.
        - Do not expect academic or formal English.
        - Do not rewrite sentences just to make them grammatically perfect.
        - Consider whether a real person would understand the user.
        - Evaluate vocabulary, clarity, expression and conversational naturalness.
        - Do not penalize the user for speaking in a simple way.
        - Reward the ability to communicate ideas and experiences.

        SCORING SYSTEM:

        Give a score between 0 and 100.

        Use these criteria:

        - Communication and understandability: 40 points
        - Vocabulary and expression: 25 points
        - Clarity and organization of ideas: 20 points
        - Conversational naturalness: 15 points

        Scoring guidelines:

        - 90-100: Communicates ideas clearly and naturally.
        - 80-89: Communicates well with minor difficulties.
        - 70-79: Generally understandable, but some ideas are unclear.
        - 60-69: Communicates basic ideas with noticeable difficulties.
        - 40-59: Communication is limited and sometimes difficult to understand.
        - 0-39: The message is very difficult to understand.

        Be fair and consistent.
        Do not give high scores automatically.
        Do not lower the score because of grammar or punctuation.
        Evaluate only the actual communication ability shown in the response.

        FEEDBACK RULES:

        - Give all feedback in Turkish.
        - Be friendly, encouraging and concise.
        - Mention what the user communicated successfully.
        - Suggest improvements only when they help real-life communication.
        - Do not invent mistakes.
        - Do not give unnecessary grammar lessons.
        - Do not judge the user's personality or intelligence.
        - Avoid repeating the same information.

        Return exactly this format:

        Score: [score]/100

        Good points:
        [Explain what the user communicated well.]

        Suggestions:
        [Give practical suggestions for better everyday communication.
        If there are no important suggestions, say the message is clear.]

        Overall feedback:
        [Give a short and encouraging evaluation in Turkish.]

        """)

        let cevap = try await oturum.respond(to: yazi)
        return cevap.content
    }


    
    
    
    
}



