import SwiftUI

struct DoctorDashboardView: View {
    @Binding var selectedRole: String?
    @Binding var path: NavigationPath
    @EnvironmentObject var userAuthVM: UserAuthViewModel
    @StateObject var viewModel = DoctorDashboardViewModel()
    @State private var selectedReport: DoctorReportResponse?
    @State private var loadingReportID: String?

    var body: some View {
        ZStack {
            AppColors.doctorGradient.ignoresSafeArea()

            VStack(spacing: 20) {
                headerView
                Spacer(minLength: 10)
                contentView.frame(maxWidth: 500).padding(.horizontal)
                Spacer()
                logoutButton.padding(.bottom, 20)
            }
            .padding()
        }
        .onAppear { reloadReports() }
    }

    private func reloadReports() {
        if let doctor = userAuthVM.currentUser {
            viewModel.fetchReports(for: doctor.id)
        }
    }

    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 5) {
            Text("Welcome,")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
            Text("Dr. \(userAuthVM.currentUser?.name ?? "Doctor")")
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
            Text("No reports assigned yet.")
                .foregroundColor(.white.opacity(0.8))
                .padding()
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
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Report Card
    private func reportCard(_ report: DoctorReportResponse) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(report.file_name)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .truncationMode(.tail)

            Text("Patient: \(report.patient.name)")
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack(spacing: 8) {
                // 📄 View Report
                Button {
                    selectedReport = report
                    path.append(report)
                } label: {
                    Label("View", systemImage: "doc.text.magnifyingglass")
                        .font(.footnote.bold())
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(8)
                        .background(Color.white)
                        .foregroundColor(AppColors.doctorPrimary)
                        .cornerRadius(10)
                }

                // 🤖 AI Recommendation
                if loadingReportID == report.id {
                    ProgressView()
                        .frame(width: 30, height: 30)
                } else {
                    Button {
                        Task {
                            loadingReportID = report.id
                            do {
                                let aiText = try await viewModel.getAIRecommendation(for: report)
                                path.append(AIRecommendationNavResponse(
                                    report_id: report.id,
                                    ai_recommendation: aiText,
                                    title: "AI Recommendation",
                                    canEdit: true
                                ))
                            } catch {
                                print("❌ Error: \(error)")
                            }
                            loadingReportID = nil
                        }
                    } label: {
                        Label("AI Reco", systemImage: "wand.and.stars")
                            .font(.footnote.bold())
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding(8)
                            .background(AppColors.doctorPrimary)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }

                // ✅ Final Recommendation
                Button {
                    if let doctorRecommendation = report.doctor_recommendation {
                        path.append(AIRecommendationNavResponse(
                            report_id: report.id,
                            ai_recommendation: doctorRecommendation,
                            title: "Final Recommendation",
                            canEdit: true
                        ))
                    }
                } label: {
                    Label("Final", systemImage: "checkmark.seal")
                        .font(.footnote.bold())
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(8)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(report.doctor_recommendation == nil)
            }
            .frame(height: 45)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 4)
    }

    // MARK: - Logout Button
    private var logoutButton: some View {
        Button(action: {
            userAuthVM.logout()
            selectedRole = nil
            path.removeLast(path.count)
        }) {
            Text("🚪 Logout")
                .font(.headline)
                .frame(maxWidth: 250)
                .padding()
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(30)
                .shadow(radius: 4)
        }
    }
}
