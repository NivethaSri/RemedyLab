//
//  RecommendationViewerView.swift
//  RemedyLab
//
//  Created by Nivetha Sri on 18/07/25.
//

import SwiftUI
import SwiftData

struct RecommendationViewerView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var report: HealthReport
    @State private var recommendationText: String
    @State private var isEditing = false
    
    init(report: HealthReport, recommendationText: String) {
        self.report = report
        _recommendationText = State(initialValue: recommendationText)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recommendation for \(report.title)")
                    .font(.title2)
                    .bold()
                Spacer()
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        saveRecommendation()
                    }
                    isEditing.toggle()
                }
                .buttonStyle(.borderedProminent)
            }
            
            if isEditing {
                TextEditor(text: $recommendationText)
                    .border(Color.gray)
                    .frame(minHeight: 300)
            } else {
                ScrollView {
                    Text(recommendationText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("View Recommendation")
    }
    
    private func saveRecommendation() {
        report.finalRecommendation = recommendationText
        do {
            try modelContext.save()
        } catch {
            print("❌ Failed to save recommendation: \(error)")
        }
    }
    
}
