MindForge_Param
MindForge_Param is a high-performance, cross-platform mobile architecture engineered for advanced multimodal processing. By leveraging Google’s Gemini LLM ecosystem, the application facilitates seamless real-time data extraction, voice interaction, and intelligent visual analysis.

Key Features
Multimodal Intelligence: Integrated with Gemini 2.5 Flash Lite for rapid, high-context data processing.

Real-time OCR: On-device computer vision for instant text extraction using Google ML Kit.

Bilingual Voice Engine: Native Speech-to-Text (STT) and Text-to-Speech (TTS) optimized for en-US and hi-IN dialects.

High-Availability Backend: A resilient, multi-tier proxy architecture ensuring constant AI uptime through intelligent failover routing.

Technical Stack
Frontend & Core
Framework: Flutter (Dart)

State Management: Provider

Security: Firebase Authentication

Native Integrations
Vision: Google ML Kit Text Recognition API.

STT: speech_to_text for live voice parsing.

TTS: flutter_tts with native platform configuration for dialect precision.

Backend & AI Infrastructure
AI Engine: Gemini 2.5 Flash Lite API.

Middleware: Node.js / Express proxy microservice.

Hosting: Render (PaaS).

Failover Logic:

Tier 1: Direct API Tunnel.

Tier 2: Hosted Proxy Server.

Tier 3: Localized Device Regex Heuristics (Edge-fallback).

Architecture Overview
The system utilizes a hybrid cloud-edge approach to minimize latency while maximizing reliability.

Build & Installation
Prerequisites
Java JDK: 21+ (Eclipse Adoptium recommended).

Flutter SDK: Latest stable version.

Android Studio: Configured with Android SDK and Command-line Tools.

Build Steps (Android)
Clone and Navigate:

Bash
git clone https://github.com/your-repo/MindForge_Param.git
cd MindForge_Param
Environment Cleanup:
Clear existing build artifacts and cache:

Bash
flutter clean
Dependency Management:
Fetch all required Dart and Flutter packages:

Bash
flutter pub get
Production Compilation:
Generate the release-ready APK:

Bash
flutter build apk
🔧 Configuration
To ensure the native TTS and STT modules function correctly, ensure the following permissions are handled in your AndroidManifest.xml:

RECORD_AUDIO

INTERNET

CAMERA (For OCR/ML Kit)

🛡️ License
This project is licensed under the MIT License.
