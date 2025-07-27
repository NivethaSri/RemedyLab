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
    @Binding var path: NavigationPath   // ✅ Path passed from ContentView

    let genders = ["Male", "Female", "Other"]
    let specializations = [
        "Cardiologist", "Orthopedic Surgeon", "Pediatrician", "Dermatologist",
        "General Physician", "Neurologist", "ENT Specialist", "Gynecologist",
        "Oncologist", "Psychiatrist"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Doctor Sign Up")
                .font(.largeTitle.bold())
            
            TextField("Name", text: $name).textFieldStyle(.roundedBorder)
            TextField("Email", text: $email).textFieldStyle(.roundedBorder)
#if os(iOS)
                .autocapitalization(.none)
#endif
            SecureField("Password", text: $password).textFieldStyle(.roundedBorder)
            SecureField("Confirm Password", text: $confirmPassword).textFieldStyle(.roundedBorder)
            
            Picker("Select Specialization", selection: $specialization) {
                ForEach(specializations, id: \.self) { spec in Text(spec).tag(spec) }
            }.pickerStyle(.menu)
            
            TextField("Experience (Years)", text: $experience)
                .textFieldStyle(.roundedBorder)
                .onChange(of: experience) { experience = $0.filter { "0123456789".contains($0) } }
            
            TextField("Contact Number", text: $contactNumber)
                .textFieldStyle(.roundedBorder)
                .onChange(of: contactNumber) { contactNumber = $0.filter { "0123456789".contains($0) } }
            
            Picker("Gender", selection: $gender) {
                ForEach(genders, id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)
            
            if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red).font(.footnote)
            }
            
            Button("Sign Up") { handleSignup() }
                .buttonStyle(.borderedProminent)
                .disabled(userAuthVM.isLoading)
            
            Button("Back to Role Selection") {
                selectedRole = nil
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
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
                contactNumber: contactNumber, experience: experience,
                gender: gender.lowercased()
            )
            
            if success {
                // ✅ Navigate to dashboard using shared path
                path.append("doctorDashboard")
            } else {
                errorMessage = userAuthVM.errorMessageAuth ?? "Something went wrong try Again"
            }
        }
    }
}

