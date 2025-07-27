import SwiftUI

struct RoleSelectionView: View {
    @Binding var selectedRole: String?
    @Binding var path: NavigationPath

    var body: some View {
        VStack(spacing: 30) {
            Text("Select Your Role")
                .font(.largeTitle.bold())

            Button("Patient") {
                selectedRole = "patient"
                path.append("patientLogin") // ✅ Navigate to Patient Login
            }
            .buttonStyle(.borderedProminent)

            Button("Doctor") {
                selectedRole = "doctor"
                path.append("doctorLogin") // ✅ Navigate to Doctor Login
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
