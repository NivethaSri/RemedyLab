//
//  Doctor.swift
//  RemedyLab
//
//  Created by Nivetha Sri on 17/07/25.
//

import Foundation
import SwiftData

@Model
class Doctor {
    @Attribute(.unique) var id: String
    var name: String
    var email: String
    var password: String
    var specialization: String
    var contactNumber: String
    var createdAt: Date
    var experience: String // ✅ Added
    init(name: String, email: String, password: String, specialization: String, contactNumber: String, experience: String, createdAt: Date = Date()) {
        self.id = UUID().uuidString
        self.name = name
        self.email = email
        self.password = password
        self.specialization = specialization
        self.contactNumber = contactNumber
        self.experience = experience
        self.createdAt = createdAt
    }
}
