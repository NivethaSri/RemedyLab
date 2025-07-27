//
//  PDFKitMacPreview.swift
//  RemedyLab
//
//  Created by Nivetha Sri on 18/07/25.
//

import SwiftUI
import PDFKit
#if os(macOS)

struct PDFKitMacPreview: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
        return pdfView
    }

    func updateNSView(_ nsView: PDFView, context: Context) {}
}
#endif
