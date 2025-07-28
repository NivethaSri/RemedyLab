//
//  DoctorDashboardViewModel.swift
//  RemedyLab
//
//  Created by Nivetha Sri on 17/07/25.
//

import SwiftUI

@MainActor
class DoctorDashboardViewModel: ObservableObject {
    @Published var reports: [DoctorReportResponse] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    init() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name("AIRecommendationUpdated"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let info = notification.object as? [String: String],
               let reportID = info["reportID"],
               let newText = info["newText"] {
                if let index = self?.reports.firstIndex(where: { $0.id == reportID }) {
                    self?.reports[index].ai_recommendation = newText
                }
            }
        }
    }

    func fetchReports(for doctorID: String) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetchedReports = try await APIService.shared.fetchDoctorReports(doctorID: doctorID)
                reports = fetchedReports
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    var groupedReports: [Date: [DoctorReportResponse]] {
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
    func getAIRecommendation(for report: DoctorReportResponse) async throws -> String {
            if let existing = report.ai_recommendation, !existing.isEmpty {
                return existing
            }

            let apiResponse = try await APIService.shared.generateAIRecommendation(reportID: report.id)
            return apiResponse.ai_recommendation
        }
}
