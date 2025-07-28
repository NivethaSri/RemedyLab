import SwiftUI
import SwiftData

struct PatientSignupView: View {
    @EnvironmentObject var userAuthVM: UserAuthViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var gender = "Female"
    @State private var age = ""
    @State private var contactNumber = ""
    @State private var errorMessage = ""

    @Binding var selectedRole: String?
    @Binding var path: NavigationPath  // ✅ Pass path from ContentView

    let genders = ["Male", "Female", "Other"]

    var body: some View {
        VStack(spacing: 20) {
            Text("Patient Sign Up")
                .font(.largeTitle.bold())

            TextField("Name", text: $name).textFieldStyle(.roundedBorder)
            TextField("Email", text: $email).textFieldStyle(.roundedBorder)
#if os(iOS)
                .autocapitalization(.none)
#endif
            SecureField("Password", text: $password).textFieldStyle(.roundedBorder)
            SecureField("Confirm Password", text: $confirmPassword).textFieldStyle(.roundedBorder)

            Picker("Gender", selection: $gender) {
                ForEach(genders, id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)

            TextField("Age", text: $age)
                .textFieldStyle(.roundedBorder)
                .onChange(of: age) { age = $0.filter { "0123456789".contains($0) } }

            TextField("Contact Number", text: $contactNumber)
                .textFieldStyle(.roundedBorder)
                .onChange(of: contactNumber) { contactNumber = $0.filter { "0123456789".contains($0) } }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Button("Sign Up") { handleSignup() }
                .buttonStyle(.borderedProminent)
                .disabled(userAuthVM.isLoading)

           
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private func handleSignup() {
        guard !name.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              !confirmPassword.isEmpty,
              !age.isEmpty,
              !contactNumber.isEmpty else {
            errorMessage = "All fields are required"
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        Task {
            let success = await userAuthVM.signupPatient(
                name: name,
                email: email,
                password: password,
                gender: gender.lowercased(),
                age: Int(age) ?? 0,  // ✅ Convert String → Int safely
                contactNumber: contactNumber
            )

            if success {
                // ✅ Use shared path for navigation
                path.append("patientDashboard")
            } else {
                errorMessage = userAuthVM.errorMessageAuth ?? "Something went wrong try Again"
            }
        }
    }
}
