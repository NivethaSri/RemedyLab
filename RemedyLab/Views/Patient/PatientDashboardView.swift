import SwiftUI
import SwiftData

struct PatientDashboardView: View {
    @Binding var selectedRole: String?
    @Binding var path: NavigationPath   // ✅ Pass path from ContentView
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var userAuthVM: UserAuthViewModel
    
    @State private var reports: [HealthReport] = []
    @State private var showUploadView = false
    @State private var selectedReport: HealthReport?

    var body: some View {
        VStack {
            Text("Welcome, \(userAuthVM.currentUser?.name ?? "Patient")!")
                .font(.largeTitle)
                .padding()

            if reports.isEmpty {
                Text("No reports uploaded yet.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    groupedReportsListView
                }
            }

            Button("Upload New Report") {
                showUploadView = true
            }
            .buttonStyle(.borderedProminent)

            Button("Logout") {
                userAuthVM.logout()
                selectedRole = nil
                path.removeLast(path.count) // ✅ Reset navigation
            }
            .buttonStyle(.borderedProminent)
        }
        .onAppear { fetchReports() }
        .popover(isPresented: $showUploadView) {
            PatientUploadReportView(onUploadComplete: {
                fetchReports()
                showUploadView = false
            })
            .environmentObject(userAuthVM)
        }
    }

    @ViewBuilder
    private var groupedReportsListView: some View {
        ForEach(groupedReports.keys.sorted(by: >), id: \.self) { date in
            Section(header: Text(dateFormatted(date))) {
                ForEach(groupedReports[date] ?? []) { report in
                    ReportRowView(
                        report: report,
                        doctorName: findDoctorName(for: report.assignedDoctorID),
                        onViewReport: {
                            selectedReport = report
                            path.append("reportViewer") // ✅ Navigate using shared path
                        },
                        onViewRecommendation: {
                            selectedReport = report
                            path.append("recommendationViewer") // ✅ Navigate using shared path
                        }
                    )
                }
            }
        }
    }

    private var groupedReports: [Date: [HealthReport]] {
        Dictionary(grouping: reports) { report in
            Calendar.current.startOfDay(for: report.uploadDate)
        }
    }

    private func dateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func fetchReports() {
        guard let patient = userAuthVM.currentUser else { return }

        let patientID = patient.id  // ✅ Capture as constant

        let descriptor = FetchDescriptor<HealthReport>(
            predicate: #Predicate { report in
                report.patientID == patientID   // ✅ Compare with constant
            },
            sortBy: [SortDescriptor(\.uploadDate, order: .reverse)]
        )

        reports = (try? modelContext.fetch(descriptor)) ?? []
    }



    private func findDoctorName(for doctorID: String?) -> String {
        guard let doctorID = doctorID else { return "Unknown Doctor" }
        let descriptor = FetchDescriptor<Doctor>(
            predicate: #Predicate { $0.id == doctorID }
        )
        if let doctor = try? modelContext.fetch(descriptor).first {
            return doctor.name
        }
        return "Unknown Doctor"
    }
}
