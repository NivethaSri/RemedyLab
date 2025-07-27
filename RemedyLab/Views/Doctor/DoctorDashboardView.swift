import SwiftUI
import SwiftData

struct DoctorDashboardView: View {
    @Binding var selectedRole: String?
    @Binding var path: NavigationPath  // ✅ Add path binding
    @EnvironmentObject var usertAuthVM: UserAuthViewModel
    @State private var selectedReport: HealthReport?
    @State private var navigateToReportViewer = false
    @State private var navigateToRecommendationViewer = false
    @State private var selectedRecommendationText = ""
    private let sampleReports: [HealthReport]

    init(selectedRole: Binding<String?>, path: Binding<NavigationPath>) {
        self._selectedRole = selectedRole
        self._path = path

        if let fileURL = Bundle.main.url(forResource: "MRS NIVETHA hgh bill", withExtension: "pdf") {
            self.sampleReports = [
                HealthReport(
                    patientID: "patient-1",
                    title: "Blood Test Report",
                    filePath: fileURL.path,
                    uploadDate: Date(),
                    assignedDoctorID: "doctor-1"
                ),
                HealthReport(
                    patientID: "patient-2",
                    title: "MRI Scan Report",
                    filePath: fileURL.path,
                    uploadDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                    assignedDoctorID: "doctor-1"
                )
            ]
        } else {
            print("❌ PDF file not found in bundle")
            self.sampleReports = []
        }
    }

    var body: some View {
        VStack {
            Text("Welcome, Dr. \(usertAuthVM.currentUser?.name ?? "Doctor")!")
                .font(.largeTitle)
                .padding()

            if sampleReports.isEmpty {
                Text("No reports assigned yet.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    groupedReportsListView
                }
            }

            Button("Logout") {
                usertAuthVM.logout()
                selectedRole = nil
                path.removeLast(path.count) // ✅ Reset navigation path
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Doctor Dashboard")
    }

    private var groupedReportsListView: some View {
        ForEach(groupedSampleReports.keys.sorted(by: >), id: \.self) { date in
            Section(header: Text(dateFormatted(date))) {
                ForEach(groupedSampleReports[date] ?? []) { report in
                    ReportRowView(
                        report: report,
                        doctorName: "Assigned by Patient",
                        onViewReport: {
                            selectedReport = report
                            // Instead of navigateToReportViewer → push a new screen
                            path.append("reportViewer")
                        },
                        onViewRecommendation: {
                            selectedReport = report
                            selectedRecommendationText = exampleRecommendation
                            path.append("recommendationViewer")
                        }
                    )
                }
            }
        }
    }

    private var groupedSampleReports: [Date: [HealthReport]] {
        Dictionary(grouping: sampleReports) { report in
            Calendar.current.startOfDay(for: report.uploadDate)
        }
    }

    private func dateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private var exampleRecommendation: String {
        """
        ### Key Abnormal Findings:
        1. **Lymphocyte Percentage**: Elevated at 48.4% (Normal: 20-40).
        2. **Eosinophils**: Elevated at 6.8% (Normal: 1-6).
        ...

        ### Medical Treatment Suggestions:
        - **Vitamin D Supplementation**
        - **Vitamin B12 Supplementation**
        - **Cholesterol Management**

        ### Lifestyle & Diet Recommendations:
        - Increase Omega-3 fatty acids, fiber intake, and antioxidants.
        - Exercise 150 mins/week.
        - Sleep 7–9 hours per night.

        ### Notes for Follow-Up:
        - Discuss elevated lymphocyte/eosinophil counts.
        - Review Vitamin D & B12 levels.
        - Address cholesterol.
        """
    }
}
