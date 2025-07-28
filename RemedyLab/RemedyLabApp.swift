import SwiftUI
import SwiftData

@main
struct RemedyLabApp: App {
    @StateObject private var userAuthVM: UserAuthViewModel

    let modelContainer: ModelContainer = {
        let schema = Schema([
            Patient.self,
            Doctor.self,
            HealthReport.self,
            Recommendation.self,
            User.self ,
            DoctorReportEntity.self// ✅ Add User model here
        ])
        let config = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("❌ Failed to initialize ModelContainer: \(error)")
        }
    }()

    init() {
        let modelContext = modelContainer.mainContext
        _userAuthVM = StateObject(wrappedValue: UserAuthViewModel(modelContext: modelContext))
        NetworkChecker.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userAuthVM)
        }
        .modelContainer(modelContainer)
    }
}
