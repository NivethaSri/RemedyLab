import SwiftUI
import PDFKit

struct ReportViewerView: View {
    let reportfilePath: String

    @State private var localFileURL: URL?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading PDF...")
            } else if let url = localFileURL {
                #if os(iOS)
                PDFKitiOSView(url: url)
                #elseif os(macOS)
                PDFKitViewMac(url: url)
                #endif
            } else if let error = errorMessage {
                Text(error).foregroundColor(.red)
            }
        }
        .onAppear { loadReport() }
    }

    private func loadReport() {
        Task {
            do {
                let localURL = getLocalFileURL()
                if FileManager.default.fileExists(atPath: localURL.path) {
                    self.localFileURL = localURL
                } else {
                    let downloadedURL = try await APIService.shared.downloadReport(filePath: reportfilePath)
                    self.localFileURL = downloadedURL
                }
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    private func getLocalFileURL() -> URL {
        let fileName = URL(fileURLWithPath: reportfilePath).lastPathComponent
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }
}
