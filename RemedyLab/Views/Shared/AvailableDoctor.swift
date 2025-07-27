//
//  AvailableDoctor.swift
//  RemedyLab
//
//  Created by Nivetha Sri on 18/07/25.
//

import Foundation

struct AvailableDoctor: Identifiable {
    let id = UUID()
    let name: String
    let specialization: String
    let experience: Int
    let profileImageName: String
}
