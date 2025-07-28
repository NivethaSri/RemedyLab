import SwiftUI

struct RecommendationViewerView: View {
    @StateObject private var viewModel: RecommendationViewerViewModel
    private let title: String
    private let canEdit: Bool  // ✅ New flag

    init(reportID: String, initialText: String?, title: String, canEdit: Bool = true) {
        self.title = title
        self.canEdit = canEdit
        _viewModel = StateObject(
            wrappedValue: RecommendationViewerViewModel(
                reportID: reportID,
                initialText: initialText
            )
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView

            if viewModel.isSaving {
                ProgressView("Saving...")
            } else if viewModel.isEditing {
                TextEditor(text: $viewModel.recommendationText)
                    .border(Color.gray)
                    .frame(minHeight: 300)
            } else {
                ScrollView {
                    Text(viewModel.recommendationText.isEmpty ? "No recommendation yet." : viewModel.recommendationText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                }
            }

            if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red)
            }

            Spacer()
        }
        .padding()
        .navigationTitle(title)
    }

    private var headerView: some View {
        HStack {
                   Text(title)
                       .font(.title2)
                       .bold()
                   Spacer()
                   if canEdit { // ✅ Show only if editing is allowed
                       Button(viewModel.isEditing ? "Save" : "Edit") {
                           viewModel.toggleEdit()
                       }
                       .buttonStyle(.borderedProminent)
                   }
               }
    }
}
