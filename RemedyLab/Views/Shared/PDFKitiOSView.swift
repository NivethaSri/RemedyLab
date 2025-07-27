//
//  PDFKitiOSView.swift
//  RemedyLab
//
//  Created by Nivetha Sri on 18/07/25.
//

import SwiftUI
import PDFKit
#if os(iOS)
struct PDFKitiOSView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        // No dynamic updates required for now
    }
}
#endif
