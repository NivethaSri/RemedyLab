Personalized Treatment App
RemedyLab – macOS & iOS App Documentation
Overview
RemedyLab is a multi-platform SwiftUI app (macOS & iOS) that connects patients and doctors for uploading health reports, AI-driven recommendations, and doctor validations.
The app integrates with a FastAPI backend that handles authentication, report storage, and AI-based treatment recommendations.
 Features
✅ Doctor & Patient Signup/Login
✅ Patients upload health reports (PDF, DOCX, CSV, JSON)
✅ Doctors can view reports assigned to them
✅ AI generates treatment recommendations (via `OPEN AI API`)
✅ Doctors can review and add recommendations
✅ Reports are displayed in dashboards (grouped by date/time)
Project Structure
Frontend (SwiftUI)
MVVM Architecture with SwiftData for local storage
APIService.swift → Handles API requests to backend
Views:
DoctorLoginView
DoctorDashboardView
PatientLoginView
PatientDashboardView
PatientUploadReportView

Backend (FastAPI)
/api/auth/* – Signup & Login APIs for doctors/patients
/api/doctor/* – Doctor listing and assigned reports
/api/patient/* – Patient-specific reports
/api/health-report/* – Report upload/download APIs
/api/ai/doctor/* – AI recommendation APIs


