//
//  ReportViewerView.swift
//  RemedyLab
//
//  Created by Nivetha Sri on 18/07/25.
//

import SwiftUI

struct ReportViewerView: View {
    let report: HealthReport
    var body: some View {
        VStack {
            Text("Viewing Report: \(report.title)")
                .font(.title2)
                .padding()
            
            if let decodedPath = report.filePath.removingPercentEncoding {
                let fileURL = URL(fileURLWithPath: decodedPath)
                
                if FileManager.default.fileExists(atPath: fileURL.path) {
#if os(macOS)
                    PDFKitMacView(url: fileURL)
#elseif os(iOS)
                    PDFKitiOSView(url: fileURL)
#endif
                } else {
                    Text("File not found at path: \(fileURL.path)")
                        .foregroundColor(.red)
                }
            } else {
                Text("Invalid file path.")
                    .foregroundColor(.red)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("   \(report.title)")
        .onAppear {
            debugPrint("Report file path: \(report.filePath)")
        }
    }
    
}
struct ReportViewerView_Previews: PreviewProvider {
    static var previews: some View {
        ReportViewerView(
            report: HealthReport(
                patientID: UUID().uuidString,
                title: "Sample PDF Report",
                filePath: "file:///Users/username/Documents/sample.pdf",
                uploadDate: Date(),
                assignedDoctorID: UUID().uuidString
            )
        )
        .previewLayout(.sizeThatFits)
        .frame(width: 400, height: 300)
        .padding()
    }
}
