import SwiftUI

struct PatientDashboardView: View {
    @Binding var selectedRole: String?
    @Binding var path: NavigationPath
    @EnvironmentObject var userAuthVM: UserAuthViewModel
    @Environment(\.modelContext) private var modelContext

    @StateObject private var viewModel = PatientDashboardViewModel()
    @State private var selectedReport: HealthReportResponse?
    @State private var showUploadView = false

    var body: some View {
        VStack(spacing: 20) {
            headerView
            contentView
            actionButtons
        }
        .onAppear {
            if let patient = userAuthVM.currentUser {
                viewModel.fetchReports(for: patient.id)
            }
        }
        .popover(isPresented: $showUploadView) {
            PatientUploadReportView(
                onUploadComplete: {
                    if let patient = userAuthVM.currentUser {
                        viewModel.fetchReports(for: patient.id)
                    }
                    showUploadView = false
                },
                modelContext: modelContext
            )
            .environmentObject(userAuthVM)
        }
    }

    // ✅ Header
    private var headerView: some View {
        Text("Welcome, \(userAuthVM.currentUser?.name ?? "Patient")!")
            .font(.largeTitle)
            .padding()
    }

    // ✅ Main Content
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            ProgressView("Loading Reports...")
        } else if let error = viewModel.errorMessage {
            Text(error).foregroundColor(.red)
        } else if viewModel.reports.isEmpty {
            Text("No reports uploaded yet.").foregroundColor(.gray)
        } else {
            reportsList
        }
    }

    // ✅ Reports List
    private var reportsList: some View {
        List {
            ForEach(viewModel.groupedReports.keys.sorted(by: >), id: \.self) { date in
                Section(header: Text(viewModel.dateFormatted(date))) {
                    ForEach(viewModel.groupedReports[date] ?? [], id: \.id) { report in
                        reportRow(report)
                    }
                }
            }
        }
    }

    // ✅ Report Row
    private func reportRow(_ report: HealthReportResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(report.file_name).font(.headline)
            Text("Doctor: \(report.doctor.name)")
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack(spacing: 16) {
                Button("View Report") {
                    selectedReport = report
                    path.append(report)
                }
                .buttonStyle(.bordered)
                Button("View Recommendation") {
                    Task {
                        do {
                            let response = try await APIService.shared.fetchDoctorRecommendation(reportID: report.id)
                            path.append(
                                AIRecommendationResponse(
                                    report_id: response.report_id,
                                    ai_recommendation: response.doctor_recommendation ?? "No Recommandation yet. Please wait.", title: "Final Recommendation", canEdit: false
                                )
                            )
                        } catch {
                            print("❌ Error: \(error)")
                        }
                    }
                }

                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
    }

    // ✅ Action Buttons
    private var actionButtons: some View {
        VStack {
            Button("Upload New Report") { showUploadView = true }
                .buttonStyle(.borderedProminent)

            Button("Logout") {
                userAuthVM.logout()
                selectedRole = nil
                path.removeLast(path.count)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
