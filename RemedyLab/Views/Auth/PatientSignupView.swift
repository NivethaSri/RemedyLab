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
    @Binding var path: NavigationPath

    let genders = ["Male", "Female", "Other"]

    var body: some View {
        ZStack {
            // 🌈 Gradient Background
            AppColors.patientGradient.ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer().frame(height: 60)

                // 🏷️ Title
                Text("Patient Sign Up")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .shadow(radius: 4)

                Spacer()

                // 📌 Floating Input Fields
                VStack(spacing: 16) {
                    customTextField("Name", text: $name)
                    customTextField("Email", text: $email)
                        .autocapitalization(.none)

                    customSecureField("Password", text: $password)
                    customSecureField("Confirm Password", text: $confirmPassword)

                    // Gender Picker
                   
                    customTextField("Age", text: $age)
                        .keyboardType(.numberPad)
                        .onChange(of: age) { age = $0.filter { "0123456789".contains($0) } }

                    customTextField("Contact Number", text: $contactNumber)
                        .keyboardType(.numberPad)
                        .onChange(of: contactNumber) { contactNumber = $0.filter { "0123456789".contains($0) } }

                    // Error Message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, 4)
                    }
                    HStack {
                        Text("Gender")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)



                    Picker("Gender", selection: $gender) {
                        ForEach(genders, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // 🌈 Sign Up Button
                    Button(action: handleSignup) {
                        Text("Sign Up")
                            .font(.headline)
                            .frame(maxWidth: 220)
                            .padding()
                            .background(AppColors.commonGradient)
                            .foregroundColor(.white)
                            .cornerRadius(30)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 4)
                    }
                    .disabled(userAuthVM.isLoading)
                }

                Spacer()
            }
            .padding()
        }
    }

    // MARK: - Reusable Custom Fields
    private func customTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(30)
            .shadow(radius: 3)
    }

    private func customSecureField(_ placeholder: String, text: Binding<String>) -> some View {
        SecureField(placeholder, text: text)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(30)
            .shadow(radius: 3)
    }

    // MARK: - Handle Signup
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
                age: Int(age) ?? 0,
                contactNumber: contactNumber
            )

            if success {
                path.append("patientDashboard")
            } else {
                errorMessage = userAuthVM.errorMessageAuth ?? "Something went wrong. Try again."
            }
        }
    }
}

struct PatientSignupView_Previews: PreviewProvider {
    static var previews: some View {
        // ✅ Create a temporary in-memory ModelContainer for preview
        let container = try! ModelContainer(for: User.self)

        PatientSignupView(
            selectedRole: .constant("patient"),
            path: .constant(NavigationPath())
        )
        .environmentObject(UserAuthViewModel(modelContext: container.mainContext))
    }
}

