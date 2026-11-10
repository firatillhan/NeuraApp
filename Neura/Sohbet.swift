//
//  Sohbet.swift
//  Neura
//
//  Created by Fırat İlhan on 10.11.2026.
//


import Foundation
import SwiftData

@Model
class Sohbet {
    var id: UUID
    var baslik: String
    var olusturmaTarihi: Date

    @Relationship(deleteRule: .cascade)
    var mesajlar: [Mesaj] = []
    
    //.cascade sayesinde bir sohbet silindiğinde ona bağlı mesajlar da otomatik silinir. Böylece iki model arasındaki ilişki tamamlanmış olacak.
    
    init(baslik: String) {
        self.id = UUID()
        self.baslik = baslik
        self.olusturmaTarihi = Date()
    }
}
