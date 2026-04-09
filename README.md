# Bachat AI

Bachat AI is a high-performance, intelligent financial ecosystem built to empower users with seamless, privacy-first, and highly intuitive expense management. Leveraging advanced native processing and state-of-the-art Large Language Models (LLMs), the application serves as a comprehensive companion for personal financial tracking, analysis, and insights.

---

## 🌟 Mission Statement
To provide a secure, localized, and context-aware financial management platform that eliminates the friction of manual data entry while maintaining strict user data privacy.

---

## ✨ Enterprise-Grade Features

### 1. Intelligent On-Device Document Parsing
* **Privacy-First OCR:** Integrates Google ML Kit's Text Recognition to process financial documents, receipts, and platform bills entirely **on-device**. Sensitive financial data never leaves the user's phone during the extraction phase, ensuring zero-knowledge privacy.
* **Instantaneous Processing:** Bypasses network latency by executing optical character recognition locally, allowing for real-time receipt scanning.

### 2. Conversational GenAI Engine
* **Context-Aware Insights:** Powered continuously by the **Gemini 2.5 Flash Lite** model. Designed specifically for low-latency, multimodal throughput, providing users with rapid, smart categorization and financial advice.
* **Multimodal Input:** Capable of understanding complex, natural language queries regarding historical spending and budget caps.

### 3. Advanced Voice Accessibility
* **Localized Speech Processing:** Utilizes robust Native Device API hooks for both Speech-To-Text (STT) and Text-To-Speech (TTS). 
* **Dialect Optimization:** Fully natively configured for both Indian regional contexts (`hi-IN`) and English (`en-US`), ensuring natural user interactions mimicking human conversational flow.

### 4. Robust Offline-First Architecture
* **Resilient Infrastructure:** Employs a dual-database model. An embedded SQLite layer guarantees the application opens instantaneously and functions flawlessly—even in dead zones without cell coverage.
* **Cloud Synchronization:** Seamless real-time state synchronization with Firebase Infrastructure (Firestore data layer and Authentication module), ensuring data consistency across multiple devices seamlessly.

### 5. Deep Financial Visualizations
* **Dynamic Analytics:** Real-time generation of holistic spending graphs and categorized charts, enabling users to maintain macro-level awareness of their financial health.

---

## 🏗 System Architecture

Bachat AI is structurally split into an ultra-responsive client application and a highly secure proxy layer.

### Frontend Client
* **Framework:** Flutter (Dart) — chosen for its ability to compile natively to ARM machine code, resulting in sustained 60-120fps UI performance via Skia/Impeller rendering engines.
* **State Management:** Provider — ensuring deterministic state hydration across the application tree and strict separation of business logic from the UI.
* **Local Storage:** SQLite (`sqflite`) alongside Shared Preferences for rapid token and cache resolution.

### Security & Proxy Microservice
* **BFF (Backend-For-Frontend) Proxy:** To secure the downstream generative AI access, the application routes AI inference requests through a dedicated Node.js/Express proxy infrastructure. 
* **Key Vaulting:** By managing API tokens on the server layer, the application entirely mitigates the risk of reverse-engineering man-in-the-middle (MITM) attacks and credential leakage on client devices.

---

## 🛡️ Security Posture

1. **API Obfuscation:** The mobile client contains zero proprietary API keys. All core processing logic is tunneled through enterprise secure channels to the proxy layer.
2. **Identity Verification:** Handled natively via Google OAuth pipelines running through Firebase Secure Authentication.
3. **Data Sovereignty:** By keeping optical processing strictly on the device hardware, personal financial habits cannot be intercepted during raw ingestion.

---

## 🚀 Building from Source

To compile the application for deployment architectures, follow standard procedural builds.

### System Prerequisites
* **Java:** JDK 21+ (`Eclipse Adoptium` configured in system PATH)
* **SDK:** Flutter SDK (^3.11.1 minimum environment)

### Compilation Steps
1. Hydrate dependencies from centralized registry:
   ```bash
   flutter pub get
   ```
2. Invalidate older compilation caches:
   ```bash
   flutter clean
   ```
3. Compile the production-ready Android package:
   ```bash
   flutter build apk --release
   ```
*(Note: A dedicated `.env` file should be orchestrated on the deployment proxy server in production mapping to the Gemini infrastructure.)*

---

© Bachat AI Systems. All rights reserved.
