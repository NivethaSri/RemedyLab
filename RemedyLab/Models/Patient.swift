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

struct UploadReportResponse: Codable {
    let status: String
    let message: String
    let data: ReportData
}

struct ReportData: Codable {
    let report_id: String
    let file_name: String
    let file_path: String
    let uploaded_at: String
    let patient_id: String
    let doctor_id: String
    let metrics: [Metric]
}

struct Metric: Codable, Hashable {
    let unit: String
    let value: String
    let test_name: String
    let technology: String
    let normal_range: String
}
