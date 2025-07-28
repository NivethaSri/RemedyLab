import SwiftUI
import SwiftData

struct PatientUploadReportView: View {
    var onUploadComplete: () -> Void

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var userAuthVM: UserAuthViewModel
    @StateObject private var viewModel: PatientUploadReportViewModel

    @State private var selectedFileURL: URL?
    @State private var reportTitle = ""
    @State private var selectedDoctorID = ""
    @State private var isFileImporterPresented = false
    @Environment(\.dismiss) private var dismiss

    init(onUploadComplete: @escaping () -> Void, modelContext: ModelContext) {
        self.onUploadComplete = onUploadComplete
        _viewModel = StateObject(wrappedValue: PatientUploadReportViewModel(modelContext: modelContext))
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Upload Health Report")
                .font(.largeTitle.bold())

            TextField("Report Title", text: $reportTitle)
                .textFieldStyle(.roundedBorder)

            Button("Select File") { isFileImporterPresented = true }
                .buttonStyle(.borderedProminent)

            if let fileURL = selectedFileURL {
                Text("Selected File: \(fileURL.lastPathComponent)")
                    .font(.footnote)
            }

            doctorPickerSection

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            if viewModel.isLoading {
                ProgressView("Processing...")
            }

            Button("Upload Report") {
                handleUpload()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)

            Spacer()
        }
        .padding()
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.pdf, .plainText, .json, .commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls): selectedFileURL = urls.first
            case .failure(let error): viewModel.errorMessage = error.localizedDescription
            }
        }
        .onAppear {
            Task { await viewModel.fetchDoctors() }
        }
        .onChange(of: viewModel.uploadSuccess) { success in
            if success {
                onUploadComplete()
                dismiss()
            }
        }
    }

    private var doctorPickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Assign Doctor").bold()

            Picker("Select Doctor", selection: $selectedDoctorID) {
                Text("Select Doctor").tag("")
                ForEach(viewModel.doctorListResponses) { doctor in
                    Text("\(doctor.name) - \(doctor.specialization)")
                        .tag(doctor.id)
                }
            }
            .pickerStyle(.menu)
            if let selected = viewModel.doctorListResponses.first(where: { $0.id == selectedDoctorID }) {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("👨‍⚕️ \(selected.name)")
                                        Text("🩺 \(selected.specialization)")
                                        Text("🧑‍⚕️ Experience: \(selected.experience) yrs")
                                    }
                                    .font(.footnote)
                                    .padding(.top, 5)
                                }
        }
    }

    private func handleUpload() {
        guard let user = userAuthVM.currentUser, user.role == "patient" else {
            viewModel.errorMessage = "Patient not authenticated"
            return
        }
        guard let fileURL = selectedFileURL else {
            viewModel.errorMessage = "Please select a file"
            return
        }
        guard !reportTitle.isEmpty else {
            viewModel.errorMessage = "Please enter a report title"
            return
        }
        guard !selectedDoctorID.isEmpty else {
            viewModel.errorMessage = "Please assign a doctor"
            return
        }

        Task {
            await viewModel.uploadReport(
                fileURL: fileURL,
                patientID: user.id,
                doctorID: selectedDoctorID
            )
        }
    }
}
