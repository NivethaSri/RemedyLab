//
//  Recommendation.swift
//  RemedyLab
//
//  Created by Nivetha Sri on 17/07/25.
//

import Foundation
import SwiftData

@Model
class Recommendation {
    @Attribute(.unique) var id: String
    var reportID: String
    var doctorID: String
    var patientID: String
    var recommendationText: String
    var createdAt: Date
    init(reportID: String, doctorID: String, patientID: String, recommendationText: String, createdAt: Date = Date()) {
        self.id = UUID().uuidString
        self.reportID = reportID
        self.doctorID = doctorID
        self.patientID = patientID
        self.recommendationText = recommendationText
        self.createdAt = createdAt
    }
}
