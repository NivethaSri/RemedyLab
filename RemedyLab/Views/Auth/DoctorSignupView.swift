import SwiftUI
import SwiftData

struct DoctorSignupView: View {
    @EnvironmentObject var userAuthVM: UserAuthViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var specialization = ""
    @State private var experience = ""
    @State private var contactNumber = ""
    @State private var gender = "Male"
    @State private var errorMessage = ""

    @Binding var selectedRole: String?
    @Binding var path: NavigationPath

    let genders = ["Male", "Female", "Other"]
    let specializations = [
        "Cardiologist", "Orthopedic Surgeon", "Pediatrician", "Dermatologist",
        "General Physician", "Neurologist", "ENT Specialist", "Gynecologist",
        "Oncologist", "Psychiatrist"
    ]

    var body: some View {
        ZStack {
            AppColors.doctorGradient.ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer().frame(height: 60)

                Text("Doctor Sign Up")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .shadow(radius: 4)

                Spacer()

                VStack(spacing: 16) {
                    customTextField("Name", text: $name)
                    customTextField("Email", text: $email)
                        .textInputAutocapitalization(.never) // ✅ Works on macOS & iOS

                    customSecureField("Password", text: $password)
                    customSecureField("Confirm Password", text: $confirmPassword)

                    // 🔹 Specialization Field Styled Like TextField
                    Menu {
                        ForEach(specializations, id: \.self) { spec in
                            Button(action: { specialization = spec }) {
                                Text(spec)
                            }
                        }
                    } label: {
                        HStack {
                            Text(specialization.isEmpty ? "Specialization" : specialization)
                                .foregroundColor(specialization.isEmpty ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(.ultraThinMaterial)
                        .cornerRadius(30)
                        .shadow(radius: 3)
                    }

                    customTextField("Experience (Years)", text: $experience)
#if os(iOS)
                        .keyboardType(.numberPad)
#endif
                        .onChange(of: experience) { experience = $0.filter { "0123456789".contains($0) } }

                    customTextField("Contact Number", text: $contactNumber)
#if os(iOS)
                        .keyboardType(.numberPad)
#endif
                        .onChange(of: contactNumber) { contactNumber = $0.filter { "0123456789".contains($0) } }

                    // 🔹 Gender Label (Left Aligned)
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

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, 4)
                    }

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
                .frame(maxWidth: 350) // ✅ Keeps iPhone-like width on macOS

                Spacer()
            }
            .padding()
        }
    }

    // MARK: - Custom TextField
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
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty,
              !specialization.isEmpty, !experience.isEmpty, !contactNumber.isEmpty else {
            errorMessage = "All fields are required"
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        Task {
            let success = await userAuthVM.signupDoctor(
                name: name,
                email: email,
                password: password,
                specialization: specialization,
                contactNumber: contactNumber,
                experience: experience,
                gender: gender.lowercased()
            )

            if success {
                path.append("doctorDashboard")
            } else {
                errorMessage = userAuthVM.errorMessageAuth ?? "Something went wrong. Try Again"
            }
        }
    }
}

struct DoctorSignupView_Previews: PreviewProvider {
    static var previews: some View {
        let container = try! ModelContainer(for: User.self)

        DoctorSignupView(
            selectedRole: .constant("doctor"),
            path: .constant(NavigationPath())
        )
        .environmentObject(UserAuthViewModel(modelContext: container.mainContext))
    }
}
