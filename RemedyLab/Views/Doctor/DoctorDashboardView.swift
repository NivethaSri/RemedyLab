import SwiftUI

struct DoctorDashboardView: View {
    @Binding var selectedRole: String?
    @Binding var path: NavigationPath
    @EnvironmentObject var userAuthVM: UserAuthViewModel
    @StateObject private var viewModel = DoctorDashboardViewModel()
    @State private var selectedReport: DoctorReportResponse?
    @Environment(\.scenePhase) private var scenePhase
    @State private var previousPathCount = 0
    @State private var loadingReportID: String? // ✅ Track which report is loading

    var body: some View {
        VStack(spacing: 20) {
            headerView
            contentView
            logoutButton
        }
        .onAppear {
            reloadReports()
        }
        .onChange(of: path.count) { oldCount, newCount in
            if newCount < oldCount {
                reloadReports() // Reload when user navigates back
            }
            previousPathCount = newCount
        }
    }

    private func reloadReports() {
        if let doctor = userAuthVM.currentUser {
            viewModel.fetchReports(for: doctor.id)
        }
    }

    // ✅ Header
    private var headerView: some View {
        Text("Welcome, Dr. \(userAuthVM.currentUser?.name ?? "Doctor")!")
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
            Text("No reports assigned yet.").foregroundColor(.gray)
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
    private func reportRow(_ report: DoctorReportResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(report.file_name).font(.headline)
            Text("Patient: \(report.patient.name)")
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack(spacing: 16) {
                Button("View Report") {
                    selectedReport = report
                    path.append(report)
                }
                .buttonStyle(.bordered)

                // ✅ AI Recommendation Button
                if loadingReportID == report.id {
                    ProgressView() // 🔄 Show loading indicator
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 30, height: 30)
                } else {
                    Button("View AI Recommendation") {
                        Task {
                            loadingReportID = report.id // Start loading
                            do {
                                let aiText = try await viewModel.getAIRecommendation(for: report)
                                let navData = AIRecommendationNavResponse(
                                    report_id: report.id,
                                    ai_recommendation: aiText,
                                    title: "AI Recommendation",
                                    canEdit: true
                                )
                                selectedReport = report
                                path.append(navData)
                            } catch {
                                print("❌ Error generating recommendation:", error.localizedDescription)
                            }
                            loadingReportID = nil // Stop loading
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }

                // ✅ Final Recommendation Button
                Button("Final Recommendation") {
                    if let doctorRecommendation = report.doctor_recommendation {
                        path.append(
                            AIRecommendationNavResponse(
                                report_id: report.id,
                                ai_recommendation: doctorRecommendation,
                                title: "Final Recommendation",
                                canEdit: true
                            )
                        )
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(report.doctor_recommendation == nil)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
    }

    // ✅ Logout
    private var logoutButton: some View {
        Button("Logout") {
            userAuthVM.logout()
            selectedRole = nil
            path.removeLast(path.count)
        }
        .buttonStyle(.borderedProminent)
    }
}
