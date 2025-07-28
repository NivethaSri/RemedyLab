import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .noData: return "No data received from the server."
        case .decodingError: return "Failed to decode the server response."
        case .serverError(let message): return "Server error: \(message)"
        case .networkError(let message): return "Network error: \(message)"
        }
    }
}

class APIService {
    static let shared = APIService()
    private init() {}

    private let baseURL = "http://127.0.0.1:8000/api" // Change when deployed

    // ✅ POST Method
    func post<T: Codable, U: Codable>(
        endpoint: String,
        payload: T,
        responseType: U.Type
    ) async throws -> U {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(data: data, response: response)

        return try decodeResponse(data, responseType: responseType)
    }

    // ✅ GET Method
    func get<U: Codable>(
        endpoint: String,
        responseType: U.Type
    ) async throws -> U {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else { throw APIError.invalidURL }
        print("url",url)
        let (data, response) = try await URLSession.shared.data(from: url)
        try validateResponse(data: data, response: response)

        return try decodeResponse(data, responseType: responseType)
    }

    // ✅ Upload Report (Multipart)
    func uploadReport(
        fileURL: URL,
        patientID: String,
        doctorID: String
    ) async throws -> UploadReportResponse {
        guard let url = URL(string: "\(baseURL)/health-report/upload-report") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = try createMultipartBody(boundary: boundary, fileURL: fileURL, patientID: patientID, doctorID: doctorID)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(data: data, response: response)

        return try decodeResponse(data, responseType: UploadReportResponse.self)
    }

    // ✅ Fetch Patient Reports
    func fetchPatientReports(patientID: String) async throws -> [HealthReportResponse] {
        let endpoint = "\(APIEndpoints.getPatientReportList)/\(patientID)"
        return try await get(endpoint: endpoint, responseType: [HealthReportResponse].self)
    }
    func fetchDoctorReports(doctorID: String) async throws -> [DoctorReportResponse] {
            guard let url = URL(string: "\(baseURL)/doctor/reports/\(doctorID)") else {
                throw APIError.invalidURL
            }

            print("📤 GET →", url)

            let (data, response) = try await URLSession.shared.data(from: url)
            try validateResponse(data: data, response: response)

            do {
                return try JSONDecoder().decode([DoctorReportResponse].self, from: data)
            } catch {
                print("❌ Decoding Error:", error)
                throw APIError.decodingError
            }
        }

    // MARK: - Helpers
    private func validateResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.noData }

        if !(200...299).contains(httpResponse.statusCode) {
            let message = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw APIError.serverError(message)
        }
        if (httpResponse.statusCode == 200) {
            let message = String(data: data, encoding: .utf8) ?? "Unknown server error"
            print("Success: \(message)")
        }
    }

    private func decodeResponse<U: Codable>(_ data: Data, responseType: U.Type) throws -> U {
        do { return try JSONDecoder().decode(U.self, from: data) }
        catch { throw APIError.decodingError }
    }

    private func createMultipartBody(
        boundary: String,
        fileURL: URL,
        patientID: String,
        doctorID: String
    ) throws -> Data {
        var body = Data()

        // File
        if let fileData = try? Data(contentsOf: fileURL) {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n")
            body.append("Content-Type: application/pdf\r\n\r\n")
            body.append(fileData)
            body.append("\r\n")
        }

        // patient_id
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"patient_id\"\r\n\r\n")
        body.append("\(patientID)\r\n")

        // doctor_id
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"doctor_id\"\r\n\r\n")
        body.append("\(doctorID)\r\n")

        body.append("--\(boundary)--\r\n")
        return body
    }
    func downloadReport(filePath: String) async throws -> URL {
            guard let url = URL(string: "\(baseURL)/health-report/download_report?file_path=\(filePath)") else {
                throw APIError.invalidURL
            }

            let (data, response) = try await URLSession.shared.data(from: url)
            try validateResponse(data: data, response: response)

            // Save file locally in Documents directory
            let fileName = URL(string: filePath)?.lastPathComponent ?? UUID().uuidString
            let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(fileName)

            try data.write(to: localURL, options: .atomic)
            return localURL
        }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

// ✅ API Response Models
struct HealthReportResponse: Codable, Identifiable, Hashable {
    let id: String
    let file_name: String
    let file_path: String
    let uploaded_at: String
    let ai_recommendation: String?
    let doctor: DoctorResponse
}

struct DoctorResponse: Codable, Hashable {
    let id: String
    let name: String
    let email: String
}


struct DoctorReportResponse: Codable, Identifiable, Hashable {
    let id: String
    let file_name: String
    let file_path: String
    let uploaded_at: String
    let patient: PatientResponse
    let metrics: [Metric]
}

struct PatientResponse: Codable, Hashable {
    let id: String
    let name: String
    let email: String
}


