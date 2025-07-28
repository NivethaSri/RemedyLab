//
//  Endpoints.swift
//  RemedyLab
//
//  Created by Nivetha Sri on 17/07/25.
//

import Foundation
enum APIEndpoints {
    static let doctorLogin = "auth/doctor/login"
    static let patientLogin = "auth/patient/login"
    static let doctorReports = "auth/doctor/reports" // Add doctor_id as needed
    static let uploadRecommendation = "health-report/add-recommendation"
    static let patientSignup = "auth/patient/signup"
    static let doctorSignup = "auth/doctor/signup"
    static let doctorList = "doctor/list"
    static let getPatientReportList = "patient/reports"

    // Add more as you grow
}
