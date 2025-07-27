import SwiftData
import Foundation // ✅ Required for Date

@Model
class User {
    @Attribute(.unique) var id: String
    var name: String
    var email: String
    var password: String
    var role: String
    var specialization: String?
    var experience: String?
    var contactNumber: String?
    var createdAt: Date?

    // ✅ Add custom initializer
    init(
        id: String,
        name: String,
        email: String,
        password: String,
        role: String,
        specialization: String? = nil,
        experience: String? = nil,
        contactNumber: String? = nil,
        createdAt: Date? = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.role = role
        self.specialization = specialization
        self.experience = experience
        self.contactNumber = contactNumber
        self.createdAt = createdAt
    }
}
