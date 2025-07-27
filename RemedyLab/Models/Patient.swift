//
//  Patient.swift
//  RemedyLab
//
//  Created by Nivetha Sri on 17/07/25.
//

import Foundation
import SwiftData

@Model
class Patient {
    @Attribute(.unique) var id: String
    var name: String
    var email: String
    var password: String
    init(name: String, email: String, password: String) {
        self.id = UUID().uuidString
        self.name = name
        self.email = email
        self.password = password
    }
}
