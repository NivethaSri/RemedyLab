//
//  ReportRowView.swift
//  RemedyLab
//
//  Created by Nivetha Sri on 17/07/25.
//

import SwiftUI
import SwiftData

struct ReportRowView: View {
    let report: HealthReport
    let doctorName: String
    let onViewReport: () -> Void
    let onViewRecommendation: () -> Void
    @State private var showPDFPreview = false
    @State private var previewURL: URL?
    @State private var recommendationText: String = ""


    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(report.title)
                .font(.headline)
            
            Text("Assigned Doctor: \(doctorName)")
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack {
                Button("View Report") {
                    onViewReport()
                }
                .buttonStyle(.bordered)
                
                Button("View Recommendation") {
                   
                    onViewRecommendation()
                }
                    
            }
        }
        .padding(.vertical, 5)
    }
    
}
struct ReportRowView_Previews: PreviewProvider {
    static var previews: some View {
        ReportRowView(
            report: HealthReport(
                patientID: "cdscdsacsa",
                title: "Sample Report",
                filePath: "/path/to/report.pdf",
                uploadDate: Date(),
                assignedDoctorID: UUID().uuidString
            ), doctorName: "Nivetha",
            onViewReport: { print("Preview: View Report tapped") },
            onViewRecommendation: { print("Preview: View Recommendation tapped") }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
