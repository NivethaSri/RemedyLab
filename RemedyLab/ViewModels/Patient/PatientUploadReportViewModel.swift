//
//  PatientUploadReportViewModel.swift
//  RemedyLab
//
//  Created by Nivetha Sri on 17/07/25.
//

import Foundation
import SwiftData

@MainActor
class PatientUploadReportViewModel: ObservableObject {
    @Published var doctorListResponses: [DoctorListResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var uploadSuccess = false

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // ✅ Fetch doctors from API
    func fetchDoctors() async {
        isLoading = true
        errorMessage = nil

        do {
            let response: [DoctorListResponse] = try await APIService.shared.get(
                endpoint: "doctor/list",
                responseType: [DoctorListResponse].self
            )
            doctorListResponses = response
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // ✅ Upload report to API and save in local DB
    func uploadReport(
        fileURL: URL,
        patientID: String,
        doctorID: String
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await APIService.shared.uploadReport(
                fileURL: fileURL,
                patientID: patientID,
                doctorID: doctorID
            )

            // ✅ Save to SwiftData
            let newReport = HealthReport(
                patientID: response.data.patient_id,
                title: response.data.file_name,
                filePath: response.data.file_path,
                uploadDate: ISO8601DateFormatter().date(from: response.data.uploaded_at) ?? Date(),
                assignedDoctorID: response.data.doctor_id
            )

            // Save metrics as JSON
            let metricsData = try JSONEncoder().encode(response.data.metrics)
            let metricsJSON = String(data: metricsData, encoding: .utf8)
            newReport.finalRecommendation = metricsJSON

            modelContext.insert(newReport)
            try? modelContext.save()

            uploadSuccess = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}



