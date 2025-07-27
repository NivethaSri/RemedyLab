//
//  Untitled.swift
//  RemedyLab
//
//  Created by nivetha.m on 27/07/25.
//

import SwiftUI
import SwiftData

struct UserLoginView: View {
    @EnvironmentObject var usertAuthVM: UserAuthViewModel
    @Binding var selectedRole: String?
    @Binding var path: NavigationPath
    
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Back Button
            HStack {
                Button(action: { selectedRole = nil }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .buttonStyle(.plain)
                .padding(.leading)
                Spacer()
            }
            
            Spacer().frame(height: 10)
            
            Text("\(selectedRole ?? "") Login")
                .font(.largeTitle.bold())
            
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
#if os(iOS)
                .autocapitalization(.none)
#endif
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            if isLoading {
                ProgressView("Logging in...")
            }
            
            Button("Login") {
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
                                if selectedRole == "doctor" {
                                    path.append("doctorDashboard")
                                } else {
                                    path.append("patientDashboard")
                                }
                            } else {
                                errorMessage = usertAuthVM.errorMessageAuth ?? "Something went wrong try Again"
                            }
                        }
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
            
            Button("Don't have an account? Sign Up") {
                if selectedRole == "patient" {
                    path.append("patientSignup")
                } else {
                    path.append("doctorSignup")
                }
            }
            .buttonStyle(.bordered)
            .disabled(isLoading)
            
            Spacer()
        }
        .padding()
    }
}
