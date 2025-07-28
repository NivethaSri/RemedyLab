//
//  Untitled.swift
//  RemedyLab
//
//  Created by Nivetha Sri on 28/07/25.
//

import SwiftData

@Model
class DoctorReportEntity {
    @Attribute(.unique) var id: String
    var file_name: String
    var file_path: String
    var uploaded_at: String
    var patient_name: String
    var patient_email: String
    var ai_recommendation: String?
    var doctor_recommendation: String?

    init(from response: DoctorReportResponse) {
        self.id = response.id
        self.file_name = response.file_name
        self.file_path = response.file_path
        self.uploaded_at = response.uploaded_at
        self.patient_name = response.patient.name
        self.patient_email = response.patient.email
        self.ai_recommendation = response.ai_recommendation
        self.doctor_recommendation = response.doctor_recommendation
    }
}
