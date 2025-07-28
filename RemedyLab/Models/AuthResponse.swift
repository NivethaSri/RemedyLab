//
//  Untitled.swift
//  RemedyLab
//
//  Created by nivetha.m on 27/07/25.
//

struct SignupResponse: Codable {
    let status: String
    let message: String
    let data: UserData
    let timestamp: String
}

struct UserData: Codable {
    let id: String   // ✅ matches API response
    let name: String
    let email: String
    let role: String
    let specialization: String?
    let experience: String?
    let contactNumber: String?
    let gender: String?
    let age: String?
}


struct PatientSignupRequest: Codable {
    let name: String
    let email: String
    let password: String
    let gender: String
    let age: Int
    let contactNumber: String   // ✅ Add this line
}


//struct PatientResponse: Codable {
//    let id: String
//    let name: String
//    let email: String
//}

struct DoctorSignupRequest: Codable {
    let name: String
    let email: String
    let password: String
    let specialization: String
    let contactNumber: String
    let experience: String
    let gender: String   // ✅ New
}
