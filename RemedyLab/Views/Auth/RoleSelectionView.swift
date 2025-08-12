import SwiftUI

struct RoleSelectionView: View {
    @Binding var selectedRole: String?
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            // 🌈 Gradient Background
            AppColors.commonGradient.ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer().frame(height: 60)

                // 🏷️ Title
                Text("Welcome to RemedyLab")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .shadow(radius: 4)

                Spacer()

                // 📌 Role Buttons Without Box
                VStack(spacing: 20) {
                    Text("Select Your Role")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .shadow(radius: 2)

                    // 👤 Patient Button
                    Button(action: {
                        selectedRole = "patient"
                        path.append("patientLogin")
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                            Text("Patient")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: 220)
                        .padding()
                        .background(AppColors.patientPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(30) // Rounded pill shape
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 4)
                    }

                    // 👨‍⚕️ Doctor Button
                    Button(action: {
                        selectedRole = "doctor"
                        path.append("doctorLogin")
                    }) {
                        HStack {
                            Image(systemName: "stethoscope")
                            Text("Doctor")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: 220)
                        .padding()
                        .background(AppColors.doctorPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 4)
                    }
                }

                Spacer()
            }
            .padding()
        }
    }
}

struct RoleSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        RoleSelectionView(
            selectedRole: .constant(nil),
            path: .constant(NavigationPath())
        )
    }
}
