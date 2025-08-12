import SwiftUI

struct AppColors {
    // 🎨 Primary Colors
    static let doctorPrimary = Color.blue
    static let patientPrimary = Color.green

    // 🌈 Gradients
    static let doctorGradient = LinearGradient(
        colors: [Color.blue.opacity(0.8), Color.teal.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    
    static let commonGradient = LinearGradient(
        colors: [Color.blue.opacity(0.8), Color.green.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let patientGradient = LinearGradient(
        colors: [Color.green.opacity(0.8), Color.teal.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
