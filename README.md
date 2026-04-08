# MindForge_Param

A high-performance cross-platform mobile application architecture utilizing Google's Gemini LLMs for advanced multimodal processing and data extraction.

## Technical Stack

### Frontend Application
- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Cloud Infrastructure:** Firebase Authentication

### Native Device Integrations
- **Speech-to-Text:** Live voice parsing using `speech_to_text`.
- **Text-to-Speech:** Native device articulation via `flutter_tts` (configured natively for `hi-IN` and `en-US` dialect control).
- **Computer Vision / OCR:** Real-time text extraction using Google ML Kit Text Recognition API.

### Backend Infrastructure & AI
- **Primary AI Engine:** Gemini 2.5 Flash Lite API.
- **Proxy Microservice:** Node.js / Express proxy server (`Backend_On_render_hosted`).
- **Proxy Deployment Environment:** Render (PaaS).
- **Failover Routing Logic:** Multi-tier fallback protection (Direct API Tunnel -> Hosted Proxy Server -> Localized Device Regex Heuristics).

## Build Instructions (Android)

1. Ensure Java JDK 21+ is installed (`Eclipse Adoptium` recommended).
2. Install the Flutter SDK and map variables.
3. Clean cache: `flutter clean`
4. Fetch dependencies: `flutter pub get`
5. Compile Release: `flutter build apk`
