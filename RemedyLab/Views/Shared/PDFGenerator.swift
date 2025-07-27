//
//  PDFGenerator.swift
//  RemedyLab
//
//  Created by Nivetha Sri on 18/07/25.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct PDFGenerator {
    
    static func generatePDF(with content: String, fileName: String) -> URL? {
        let pageWidth: CGFloat = 595.2  // A4 width in points
        let pageHeight: CGFloat = 841.8 // A4 height in points
        
#if os(macOS)
        let data = NSMutableData()
        guard let consumer = CGDataConsumer(data: data as CFMutableData) else {
            print("❌ Failed to create CGDataConsumer")
            return nil
        }
        
        var mediaBox = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        guard let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            print("❌ Failed to create CGContext")
            return nil
        }
        
        pdfContext.beginPage(mediaBox: &mediaBox)
        
        let textRect = CGRect(x: 20, y: 20, width: pageWidth - 40, height: pageHeight - 40)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12)
        ]
        
        (content as NSString).draw(in: textRect, withAttributes: attributes)
        
        pdfContext.endPage()
        pdfContext.closePDF()
        
        // Save to file
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
        data.write(to: fileURL, atomically: true)
        return fileURL
        
#elseif os(iOS)
        let format = UIGraphicsPDFRendererFormat()
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12)
            ]
            let textRect = CGRect(x: 20, y: 20, width: pageWidth - 40, height: pageHeight - 40)
            (content as NSString).draw(in: textRect, withAttributes: attributes)
        }
        
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("❌ Failed to write PDF on iOS: \(error)")
            return nil
        }
#endif
    }
}
