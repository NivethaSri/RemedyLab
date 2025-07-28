import Foundation

@MainActor
class RecommendationViewerViewModel: ObservableObject {
    @Published var recommendationText: String
    @Published var isEditing = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let reportID: String

    init(reportID: String, initialText: String?) {
        self.reportID = reportID
        self.recommendationText = initialText ?? ""
    }

    func toggleEdit() {
        if isEditing { saveRecommendation() }
        isEditing.toggle()
    }

    func saveRecommendation() {
        isSaving = true
        errorMessage = nil

        Task {
            do {
                try await APIService.shared.saveDoctorRecommendation(
                    reportID: reportID,
                    recommendation: recommendationText
                )
            } catch {
                errorMessage = "❌ Failed to save recommendation: \(error.localizedDescription)"
            }
            isSaving = false
        }
    }
}
