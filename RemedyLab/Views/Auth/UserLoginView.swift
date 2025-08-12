import SwiftUI

struct UserLoginView: View {
    @EnvironmentObject var usertAuthVM: UserAuthViewModel
    @Binding var selectedRole: String?
    @Binding var path: NavigationPath

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        ZStack {
            // 🌈 Role-based gradient
            (selectedRole == "doctor" ? AppColors.doctorGradient : AppColors.patientGradient)
                .ignoresSafeArea()

            VStack(spacing: 25) {
                Spacer().frame(height: 60)

                // 🏷️ Title
                Text("\((selectedRole ?? "").capitalized) Login")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .shadow(radius: 4)

                Spacer()

                // 📌 Floating Fields & Buttons
                VStack(spacing: 18) {
                    // ✉️ Email
                    TextField("Email", text: $email)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(30)
                        .shadow(radius: 3)

                    // 🔒 Password
                    SecureField("Password", text: $password)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(30)
                        .shadow(radius: 3)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, 4)
                    }

                    if isLoading {
                        ProgressView("Logging in...")
                            .padding(.top, 4)
                    }

                    // 🌈 Gradient Rounded Login Button
                    Button(action: handleLogin) {
                        Text("Login")
                            .font(.headline)
                            .frame(maxWidth: 220)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(30)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 4)
                    }
                    .disabled(isLoading)

                    // 🔗 Sign-up Link
                    Button(action: handleSignup) {
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .foregroundColor(.white.opacity(0.8))
                            Text("Sign Up")
                                .foregroundColor(.yellow)
                                .fontWeight(.bold)
                                .underline()
                        }
                        .font(.callout)
                        .shadow(radius: 2)
                    }
                    .disabled(isLoading)
                }

                Spacer()
            }
            .padding()
        }
    }

    // MARK: - Actions
    private func handleLogin() {
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill all fields"
        } else {
            isLoading = true
            errorMessage = ""
            Task {
                let success = await usertAuthVM.login(email: email, password: password, role: selectedRole!)
                DispatchQueue.main.async {
                    isLoading = false
                    if success {
                        path.append(selectedRole == "doctor" ? "doctorDashboard" : "patientDashboard")
                    } else {
                        errorMessage = usertAuthVM.errorMessageAuth ?? "Something went wrong. Try again."
                    }
                }
            }
        }
    }

    private func handleSignup() {
        if selectedRole == "patient" {
            path.append("patientSignup")
        } else {
            path.append("doctorSignup")
        }
    }
}

struct UserLoginView_Previews: PreviewProvider {
    static var previews: some View {
        UserLoginView(
            selectedRole: .constant("Patient"),
            path: .constant(NavigationPath())
        )
    }
}
