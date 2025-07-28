import SwiftData
import Foundation

@Model
class HealthReport {
    @Attribute(.unique) var id: String
    var patientID: String
    var title: String
    var filePath: String
    var uploadDate: Date
    var assignedDoctorID: String?
    var finalRecommendation: String?
    
    // ✅ Store metrics as JSON string
    var metricsJSON: String?

    init(patientID: String, title: String, filePath: String, uploadDate: Date, assignedDoctorID: String?, finalRecommendation: String? = nil, metricsJSON: String? = nil) {
        self.id = UUID().uuidString
        self.patientID = patientID
        self.title = title
        self.filePath = filePath
        self.uploadDate = uploadDate
        self.assignedDoctorID = assignedDoctorID
        self.finalRecommendation = finalRecommendation
        self.metricsJSON = metricsJSON
    }
}



