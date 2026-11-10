//
//  Mesaj.swift
//  Neura
//
//  Created by Fırat İlhan on 10.11.2026.
//


import Foundation
import SwiftData

@Model
class Mesaj {
    var icerik: String
    var kullaniciMi: Bool

    var sohbet: Sohbet?

    init(icerik: String, kullaniciMi: Bool) {
        self.icerik = icerik
        self.kullaniciMi = kullaniciMi
    }
}