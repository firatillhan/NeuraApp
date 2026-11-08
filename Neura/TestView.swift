//
//  ContentView 2.swift
//  Neura
//
//  Created by Fırat İlhan on 8.11.2026.
//


import SwiftUI
import FoundationModels

struct TestView: View {
    @State private var kullaniciYazi = ""
    @State private var sonuc2 = ""
    @State private var yukleniyor = false
    
    var body: some View {
        VStack {
            Text("\(sonuc2)")
                .textSelection(.enabled)
            if yukleniyor {
                ProgressView()
                    .controlSize(.large)
                    .padding()
            }
            TextField("Bir mesaj yazın...", text: $kullaniciYazi)
                .padding(12)
                .font(.body)
                .background(.white, in: RoundedRectangle(cornerRadius: 12))
                .textFieldStyle(.plain)
            Button {
                Task{
                    let mesaj = kullaniciYazi
                    yukleniyor = true
                    kullaniciYazi = ""
                    
                    do {
                        sonuc2 = try await modeliTestEt(mesaj)

                    } catch {
                        sonuc2 = error.localizedDescription
                    }
                    yukleniyor = false

                }
            } label: {
                Text("Gönder")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.brown)
                    .cornerRadius(16)
            }
        }
                .padding(12)
                .background(.gray)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 12)
    }
    

    
    func modeliTestEt(_ yazi: String) async throws -> String {
        let oturum2 = LanguageModelSession()
        let sonuc2 = try await oturum2.respond(to: yazi)
        return sonuc2.content
        //Çünkü fonksiyonun görevi veriyi almak ve döndürmek; hatanın nasıl gösterileceğine ise onu çağıran taraf karar vermeli. Bu nedenle testet fonksiyonundaki do catch bloğunu kaldırıp buton içine koydum.
    }
}
