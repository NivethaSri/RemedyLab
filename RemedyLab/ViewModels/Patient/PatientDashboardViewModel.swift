//
//  PatientDashboardViewModel.swift
//  RemedyLab
//
//  Created by Nivetha Sri on 17/07/25.
//

import SwiftUI

@MainActor
class PatientDashboardViewModel: ObservableObject {
    @Published var reports: [HealthReportResponse] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func fetchReports(for patientID: String) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetchedReports = try await APIService.shared.fetchPatientReports(patientID: patientID)
                reports = fetchedReports
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    // ✅ Group reports by date
    var groupedReports: [Date: [HealthReportResponse]] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"

        return Dictionary(grouping: reports) { report in
            if let parsedDate = formatter.date(from: report.uploaded_at) {
                return Calendar.current.startOfDay(for: parsedDate)
            }
            return Date()
        }
    }

    func dateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
