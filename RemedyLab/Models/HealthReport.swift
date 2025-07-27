//
//  HealthReport.swift
//  RemedyLab
//
//  Created by Nivetha Sri on 17/07/25.
//

import Foundation
import SwiftData

@Model
class HealthReport {
    @Attribute(.unique) var id: String
    var patientID: String
    var title: String
    var filePath: String
    var uploadDate: Date
    var assignedDoctorID: String?
    var finalRecommendation: String? // Add this field



    init(patientID: String, title: String, filePath: String, uploadDate: Date, assignedDoctorID: String?, finalRecommendation: String? = nil) {
        self.id = UUID().uuidString
        self.patientID = patientID
        self.title = title
        self.filePath = filePath
        self.uploadDate = uploadDate
        self.assignedDoctorID = assignedDoctorID
        self.finalRecommendation = finalRecommendation
    }

}
