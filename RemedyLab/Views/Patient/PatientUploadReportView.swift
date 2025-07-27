import SwiftUI
import SwiftData

struct PatientUploadReportView: View {
    var onUploadComplete: () -> Void
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var userAuthVM: UserAuthViewModel  // ✅ Unified Auth ViewModel
    @State private var selectedFileURL: URL?
    @State private var reportTitle = ""
    @State private var selectedDoctorID = ""
    @State private var errorMessage = ""
    @State private var isFileImporterPresented = false
    @Environment(\.dismiss) private var dismiss

    // ✅ Currently hardcoded doctors
    private let availableDoctors: [AvailableDoctor] = [
        AvailableDoctor(name: "Dr. Nivetha M", specialization: "Cardiologist", experience: 10, profileImageName: "person.fill"),
        AvailableDoctor(name: "Dr. Arjun S", specialization: "Orthopedic", experience: 8, profileImageName: "stethoscope"),
        AvailableDoctor(name: "Dr. Priya V", specialization: "Pediatrician", experience: 5, profileImageName: "cross.case.fill")
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("Upload Health Report")
                .font(.largeTitle.bold())

            TextField("Report Title", text: $reportTitle)
                .textFieldStyle(.roundedBorder)

            Button("Select File") {
                isFileImporterPresented = true
            }
            .buttonStyle(.borderedProminent)

            if let fileURL = selectedFileURL {
                Text("Selected File: \(fileURL.lastPathComponent)")
                    .font(.footnote)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Assign Doctor").bold()

                Picker("Select Doctor", selection: $selectedDoctorID) {
                    Text("Select Doctor").tag("")
                    ForEach(availableDoctors) { doctor in
                        Text(doctor.name).tag(doctor.id.uuidString)
                    }
                }
                .pickerStyle(.menu)

                if let selected = availableDoctors.first(where: { $0.id.uuidString == selectedDoctorID }) {
                    AvailableDoctorRowView(doctor: selected)
                        .padding(.top, 5)
                }
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Button("Upload Report") {
                handleUpload()
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.pdf, .plainText, .json, .commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                selectedFileURL = urls.first
            case .failure(let error):
                errorMessage = "Failed to select file: \(error.localizedDescription)"
            }
        }
    }

    // ✅ Final handleUpload() Logic
    private func handleUpload() {
        guard let user = userAuthVM.currentUser, user.role == "patient" else {
            errorMessage = "Patient not authenticated"
            return
        }
        guard let fileURL = selectedFileURL else {
            errorMessage = "Please select a file"
            return
        }
        guard !reportTitle.isEmpty else {
            errorMessage = "Please enter a report title"
            return
        }
        guard !selectedDoctorID.isEmpty else {
            errorMessage = "Please assign a doctor"
            return
        }

        let newReport = HealthReport(
            patientID: user.id,
            title: reportTitle,
            filePath: fileURL.path,
            uploadDate: Date(),
            assignedDoctorID: selectedDoctorID
        )

        do {
            modelContext.insert(newReport)
            try modelContext.save()  // ✅ Persist data
            errorMessage = ""
            onUploadComplete()
            dismiss()
        } catch {
            errorMessage = "Failed to save report: \(error.localizedDescription)"
        }
    }
}

// ✅ Preview
struct PatientUploadReportView_Previews: PreviewProvider {
    static var previews: some View {
        let schema = Schema([Patient.self, HealthReport.self])
        let container = try! ModelContainer(for: schema)

        let mockUser = Patient(name: "Preview User", email: "preview@example.com", password: "password")
        container.mainContext.insert(mockUser)

        let userAuthVM = UserAuthViewModel(modelContext: container.mainContext)
        userAuthVM.currentUser = User(
            id: UUID().uuidString,
            name: "Preview User",
            email: "preview@example.com",
            password: "password",
            role: "patient",
            createdAt: Date()
        )

        return PatientUploadReportView(onUploadComplete: {})
            .environmentObject(userAuthVM)
            .modelContainer(container)
            .frame(width: 500, height: 700)
            .previewDisplayName("Patient Upload Report Preview")
    }
}
