//
//  AvailableDoctorRowView.swift
//  RemedyLab
//
//  Created by Nivetha Sri on 18/07/25.
//

import SwiftUI

struct AvailableDoctorRowView: View {
    let doctor: AvailableDoctor
    
    var body: some View {
        HStack {
            Image(systemName: doctor.profileImageName)
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.trailing, 5)
            VStack(alignment: .leading) {
                Text(doctor.name).bold()
                Text(doctor.specialization)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("\(doctor.experience) years experience")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
}
struct AvailableDoctorRowView_Previews: PreviewProvider {
    static var previews: some View {
        AvailableDoctorRowView(
            doctor: AvailableDoctor(
                name: "Dr. Nivetha M",
                specialization: "Cardiologist",
                experience: 10,
                profileImageName: "person.fill"
            )
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
