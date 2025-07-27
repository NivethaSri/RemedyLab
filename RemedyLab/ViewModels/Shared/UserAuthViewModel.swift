import SwiftUI
import SwiftData

@MainActor
class UserAuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessageAuth: String?
    @Published var isLoading = false

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: 🔹 Doctor Signup
    func signupDoctor(name: String, email: String, password: String,
                      specialization: String, contactNumber: String,
                      experience: String, gender: String) async -> Bool {
        let payload = DoctorSignupRequest(
            name: name,
            email: email,
            password: password,
            specialization: specialization,
            contactNumber: contactNumber,
            experience: experience,
            gender: gender
        )

        return await performSignup(
            endpoint: APIEndpoints.doctorSignup,
            payload: payload,
            password: password
        )
    }

    // MARK: 🔹 Patient Signup
    func signupPatient(name: String, email: String, password: String,
                       gender: String, age: Int, contactNumber: String) async -> Bool {
        let payload = PatientSignupRequest(
            name: name,
            email: email,
            password: password,
            gender: gender,
            age: age,
            contactNumber: contactNumber
        )

        return await performSignup(
            endpoint: APIEndpoints.patientSignup,
            payload: payload,
            password: password
        )
    }

    // MARK: 🔹 Generic Signup Function
    private func performSignup<T: Codable>(endpoint: String, payload: T, password: String) async -> Bool {
        guard NetworkChecker.shared.isConnected else {
            self.errorMessageAuth = "No Internet Connection"
            return false
        }

        self.isLoading = true
        self.errorMessageAuth = nil

        do {
            let response = try await APIService.shared.post(
                endpoint: endpoint,
                payload: payload,
                responseType: SignupResponse.self
            )

            await saveOrUpdateUser(response: response, password: password)
            return true

        } catch let error as APIError {
            self.errorMessageAuth = error.errorDescription
            self.isLoading = false
            return false

        } catch {
            self.errorMessageAuth = "Unexpected error: \(error.localizedDescription)"
            self.isLoading = false
            return false
        }
    }

    // MARK: 🔹 Save or Update User in SwiftData
    private func saveOrUpdateUser(response: SignupResponse, password: String) async {
        let data = response.data
        let fetch = FetchDescriptor<User>(predicate: #Predicate { $0.id == data.id })

        if let existingUser = try? modelContext.fetch(fetch).first {
            // ✅ Update existing user
            existingUser.name = data.name
            existingUser.email = data.email
            existingUser.password = password
            existingUser.role = data.role
            existingUser.specialization = data.specialization
            existingUser.experience = data.experience
            existingUser.contactNumber = data.contactNumber
            existingUser.createdAt = Date()
        } else {
            // ✅ Insert new user
            let newUser = User(
                id: data.id,
                name: data.name,
                email: data.email,
                password: password,
                role: data.role,
                specialization: data.specialization,
                experience: data.experience,
                contactNumber: data.contactNumber,
                createdAt: Date()
            )
            modelContext.insert(newUser)
        }

        try? modelContext.save()

        self.currentUser = try? modelContext.fetch(fetch).first
        self.isAuthenticated = true
        self.isLoading = false
    }

    // MARK: 🔹 Login Function
    func login(email: String, password: String, role: String) async -> Bool {
        guard NetworkChecker.shared.isConnected else {
            self.errorMessageAuth = "No internet connection."
            return false
        }

        self.isLoading = true
        self.errorMessageAuth = nil

        do {
            struct LoginRequest: Codable {
                let email: String
                let password: String
            }

            let payload = LoginRequest(email: email, password: password)

            // ✅ Choose endpoint based on role
            let endpoint: String
            if role == "doctor" {
                endpoint = APIEndpoints.doctorLogin
            } else {
                endpoint = APIEndpoints.patientLogin
            }

            // ✅ Make API call
            let response = try await APIService.shared.post(
                endpoint: endpoint,
                payload: payload,
                responseType: SignupResponse.self
            )


            let userData = response.data
            await saveOrUpdateUser(
                response: SignupResponse( // ✅ Reuse same model structure
                    status: response.status,
                    message: response.message,
                    data: userData,
                    timestamp: response.timestamp
                ),
                password: password
            )

            return true

        } catch let error as APIError {
            self.errorMessageAuth = error.errorDescription
            self.isLoading = false
            return false

        } catch {
            self.errorMessageAuth = "Unexpected error: \(error.localizedDescription)"
            self.isLoading = false
            return false
        }
    }
    func logout() {
        isAuthenticated = false
        currentUser = nil
    }

}
