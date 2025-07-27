import SwiftUI

struct ContentView: View {
    @EnvironmentObject var usertAuthVM: UserAuthViewModel
    @State private var path = NavigationPath()
    @State private var selectedRole: String? = nil

    var body: some View {
        NavigationStack(path: $path) {
            RoleSelectionView(selectedRole: $selectedRole, path: $path)
                .navigationDestination(for: String.self) { value in
                    switch value {
                    case "doctorLogin":
                        UserLoginView(selectedRole: $selectedRole, path: $path)
                            .environmentObject(usertAuthVM)

                    case "patientLogin":
                        UserLoginView(selectedRole: $selectedRole, path: $path)
                            .environmentObject(usertAuthVM)

                    case "doctorSignup":
                        DoctorSignupView(selectedRole: $selectedRole, path: $path)
                            .environmentObject(usertAuthVM)

                    case "patientSignup":
                        PatientSignupView(selectedRole: $selectedRole, path: $path)
                            .environmentObject(usertAuthVM)

                    case "doctorDashboard":
                        DoctorDashboardView(selectedRole: $selectedRole, path: $path)
                            .environmentObject(usertAuthVM)

                    case "patientDashboard":
                        PatientDashboardView(selectedRole: $selectedRole, path: $path)
                            .environmentObject(usertAuthVM)

                    default:
                        Text("Unknown screen")
                    }
                }
        }
    }
}
