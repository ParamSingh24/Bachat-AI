import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../providers/expense_provider.dart';
import '../services/pdf_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          children: [
            // Google Login Card
            StreamBuilder<User?>(
              stream: authService.authStateChanges,
              builder: (context, snapshot) {
                final user = snapshot.data;
                if (user != null) {
                  return Card(
                    color: AppTheme.surfaceContainerLowest,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                            backgroundColor: AppTheme.primary,
                            child: user.photoURL == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
                          ),
                          const SizedBox(height: 16),
                          Text(user.displayName ?? 'Google User', style: Theme.of(context).textTheme.headlineSmall),
                          Text(user.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => authService.signOut(),
                            icon: const Icon(Icons.logout),
                            label: const Text('Sign Out'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100], foregroundColor: Colors.red[900]),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Card(
                    color: AppTheme.surfaceContainerLowest,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text("Cloud Sync Offline", style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 8),
                          const Text("Sign in to sync your expenses with Firebase securely."),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => authService.signInWithGoogle(),
                            icon: const Icon(Icons.login),
                            label: const Text('Sign In with Google'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryContainer, foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            // Settings Card - Language
            Card(
              child: ListTile(
                title: Text("Hindi Language", style: Theme.of(context).textTheme.bodyLarge),
                subtitle: Text("Voice & insights output language", style: Theme.of(context).textTheme.bodySmall),
                trailing: Switch(
                  value: settings.isHindi,
                  activeColor: AppTheme.primary,
                  onChanged: (val) {
                    settings.toggleLanguage();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Settings Card - Demo Mode Toggle
            Card(
              child: ListTile(
                title: Text("Running in Background", style: Theme.of(context).textTheme.bodyLarge),
                subtitle: Text("Mock OCR scan data", style: Theme.of(context).textTheme.bodySmall),
                trailing: Switch(
                   value: settings.isDemoMode,
                   activeColor: AppTheme.secondary,
                   onChanged: (val) {
                      settings.toggleDemoMode();
                   },
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Gemini API Configuration
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Gemini AI API Key", style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: context.watch<SettingsProvider>().geminiApiKey,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Enter your AI key securely...',
                      filled: true,
                      fillColor: AppTheme.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                       context.read<SettingsProvider>().setGeminiApiKey(value.trim());
                    },
                  ),
                  const SizedBox(height: 8),
                  Text("Required for adult-response Chatbot features.", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.outlineVariant)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // PDF Export Action
            Card(
              child: ListTile(
                title: Text("Export PDF Report", style: Theme.of(context).textTheme.bodyLarge),
                leading: const Icon(Icons.picture_as_pdf, color: AppTheme.primary),
                onTap: () {
                   final provider = context.read<ExpenseProvider>();
                   PdfService.generateAndPrintReport(provider.expenses, provider.totalExpenses);
                },
              ),
            ),
            
            const SizedBox(height: 120), // padding for FAB missing
          ],
        ),
      ),
    );
  }
}
