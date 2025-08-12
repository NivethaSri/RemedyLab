import SwiftUI
import SwiftData

struct PatientDashboardView: View {
    @Binding var selectedRole: String?
    @Binding var path: NavigationPath
    @EnvironmentObject var userAuthVM: UserAuthViewModel
    @Environment(\.modelContext) private var modelContext

    @StateObject var viewModel = PatientDashboardViewModel()
    @State private var selectedReport: HealthReportResponse?
    @State private var showUploadView = false

    var body: some View {
        ZStack {
            AppColors.patientGradient.ignoresSafeArea()

            VStack(spacing: 16) {
                headerView
                    .padding(.top, 30)

                contentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal)

                actionButtons
                    .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            if let patient = userAuthVM.currentUser {
                viewModel.fetchReports(for: patient.id)
            }
        }
        .sheet(isPresented: $showUploadView) {
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

    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 5) {
            Text("Welcome,")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
            Text(userAuthVM.currentUser?.name ?? "Patient")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
                .shadow(radius: 4)
        }
    }

    // MARK: - Main Content
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            ProgressView("Loading Reports...")
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else if let error = viewModel.errorMessage {
            Text(error)
                .foregroundColor(.red)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
        } else if viewModel.reports.isEmpty {
            Spacer()
            Text("No reports uploaded yet.")
                .foregroundColor(.white.opacity(0.9))
                .font(.headline)
                .padding()
            Spacer()
        } else {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.groupedReports.keys.sorted(by: >), id: \.self) { date in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(viewModel.dateFormatted(date))
                                .font(.headline)
                                .foregroundColor(.white)

                            VStack(spacing: 12) {
                                ForEach(viewModel.groupedReports[date] ?? [], id: \.id) { report in
                                    reportCard(report)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.bottom, 10)
            }
        }
    }

    // MARK: - Report Card
    private func reportCard(_ report: HealthReportResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(report.file_name)
                .font(.headline)
                .lineLimit(1)

            Text("Doctor: \(report.doctor.name)")
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack(spacing: 10) {
                // 📄 View Report Button
                Button {
                    selectedReport = report
                    path.append(report)
                } label: {
                    Label("View", systemImage: "doc.text.magnifyingglass")
                        .font(.footnote.bold())
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .foregroundColor(AppColors.doctorPrimary)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }

                // 💡 Recommendations Button
                Button {
                    Task {
                        do {
                            let response = try await APIService.shared.fetchDoctorRecommendation(reportID: report.id)
                            path.append(
                                AIRecommendationNavResponse(
                                    report_id: response.report_id,
                                    ai_recommendation: response.doctor_recommendation ?? "No Recommendation yet.",
                                    title: "Recommendations",
                                    canEdit: false
                                )
                            )
                        } catch {
                            print("❌ Error: \(error)")
                        }
                    }
                } label: {
                    Label("Recommendations", systemImage: "lightbulb")
                        .font(.footnote.bold())
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppColors.doctorPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 4)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 14) {
            Button(action: { showUploadView = true }) {
                Text("📤 Upload New Report")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.commonGradient)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .shadow(radius: 4)
            }

            Button(action: {
                userAuthVM.logout()
                selectedRole = nil
                path.removeLast(path.count)
            }) {
                Text("🚪 Logout")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.85))
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .shadow(radius: 4)
            }
        }
        .frame(maxWidth: 350) // ✅ Center buttons
    }
}

struct PatientDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let container = try! ModelContainer(for: User.self)

        let mockUser = User(
            id: UUID().uuidString,
            name: "Nivetha",
            email: "nivetha@example.com",
            password: "123456",
            role: "patient",
            specialization: nil,
            experience: nil,
            contactNumber: "9876543210",
            createdAt: Date()
        )

        let mockVM = UserAuthViewModel(modelContext: container.mainContext)
        mockVM.currentUser = mockUser

        let sampleReports: [HealthReportResponse] = [
            HealthReportResponse(
                id: "1",
                file_name: "Mrs_Nivetha_Report.pdf",
                file_path: "/reports/sample.pdf",
                uploaded_at: "2025-08-01T10:00:00Z",
                ai_recommendation: nil,
                doctor_recommendation: "Exercise 30 mins daily.",
                doctor: DoctorResponse(id: "D1", name: "Riyashini", email: "doc1@test.com")
            ),
            HealthReportResponse(
                id: "2",
                file_name: "BloodTest_July.pdf",
                file_path: "/reports/sample2.pdf",
                uploaded_at: "2025-07-28T10:00:00Z",
                ai_recommendation: "Low-carb diet.",
                doctor_recommendation: nil,
                doctor: DoctorResponse(id: "D2", name: "Kandeeban", email: "doc2@test.com")
            )
        ]

        let dashboardVM = PatientDashboardViewModel()
        dashboardVM.reports = sampleReports

        return PatientDashboardView(
            selectedRole: .constant("patient"),
            path: .constant(NavigationPath())
        )
        .environmentObject(mockVM)
        .environment(\.modelContext, container.mainContext)
        .environmentObject(dashboardVM)
    }
}
