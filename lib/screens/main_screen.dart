import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';
import 'report_screen.dart';
import 'profile_screen.dart';
import '../theme/app_theme.dart';
import '../services/ocr_service.dart';
import '../providers/settings_provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../services/ai_logic_engine.dart';
import '../services/tts_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/receipt_parser.dart';
import 'ai_chat_screen.dart';
import 'reports_history_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final OcrService _ocrService = OcrService();
  final TtsService _ttsService = TtsService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isProcessing = false;
  bool _isListening = false;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const ReportScreen(),
    const AiChatScreen(),
    const ReportsHistoryScreen(), 
  ];

  void _globalScanReceipt() async {
    final settings = context.read<SettingsProvider>();
    setState(() => _isProcessing = true);
    
    // Always open the real camera so it looks authentic
    final rawResult = await _ocrService.scanReceipt(settings.geminiApiKey);
    
    if (rawResult != null) {
      if (settings.isDemoMode) {
        // Simulate heavy AI processing friction
        await Future.delayed(const Duration(seconds: 3));
        
        // --- DEMO MODE: Inject Precise Mock Data ---
        final expense = Expense(
          amount: 1233.0,
          date: DateTime.now(),
          vendor: 'Savana',
          category: 'Shopping',
        );
        final provider = context.read<ExpenseProvider>();
        await provider.addExpense(expense, persist: true); // Show on dashboard
        
        if (mounted) {
           String feedback = settings.isHindi 
               ? "परम जी, थोड़े कपड़े कम खरीदिए, आप ज्यादा खरीद रहे हैं!"
               : "Param, you are buying too much clothes please drop it low";
           _showAiFeedback(feedback, settings.isHindi);
        }
      } else {
        // --- PROCESS LEGITIMATE DATA ---
        final expense = Expense(
          amount: rawResult['amount'] ?? 0.0,
          date: rawResult['date'] ?? DateTime.now(),
          vendor: rawResult['vendor'] ?? 'Unknown Vendor',
          category: rawResult['category'] ?? 'Other',
        );

        if (mounted) {
          final provider = context.read<ExpenseProvider>();
          await provider.addExpense(expense, persist: true);
          
          double catTotal = provider.categoryBreakdown[expense.category] ?? 0.0;
          String suggestion = BudgetStrategist.generateLocalSuggestion(
            expense.amount, expense.category, catTotal, isHindi: settings.isHindi
          );
          _showAiFeedback(suggestion, settings.isHindi);
        }
      }
    }
    
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  void _listenToVoice() async {
    final settings = context.read<SettingsProvider>();
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) async {
          if (val.finalResult) {
            setState(() { _isListening = false; _isProcessing = true; });
            
            Map<String, dynamic>? rawResult;
            
            if (settings.isDemoMode) {
               await Future.delayed(const Duration(seconds: 1));
               rawResult = {
                 'amount': 90.0,
                 'vendor': 'Zomato',
                 'category': 'Food',
                 'date': DateTime.now(),
               };
            } else {
               rawResult = await ReceiptParser.parseWithAI(val.recognizedWords, settings.geminiApiKey);
            }
            
            if (rawResult != null) {
              final expense = Expense(
                amount: rawResult['amount'] ?? 0.0,
                date: rawResult['date'] ?? DateTime.now(),
                vendor: rawResult['vendor'] ?? 'Unknown',
                category: rawResult['category'] ?? 'Other',
              );
              
              if (mounted && expense.amount > 0) {
                final provider = context.read<ExpenseProvider>();
                await provider.addExpense(expense, persist: true);
                
                String feedback = settings.isHindi ? '₹${expense.amount} jud gaye.' : 'Successfully added ₹${expense.amount} to ${expense.category}.';
                final vendorLower = expense.vendor.toLowerCase();
                if (vendorLower.contains('zomato') || vendorLower.contains('swiggy')) {
                   feedback = settings.isHindi
                       ? "परम जी, बाहर का खाना थोड़ा कम खाइए। यह आपकी हेल्थ और बजट दोनों के लिए अच्छा है।"
                       : "Param, eat home-cooked food. It is better for your health and budget.";
                }
                
                _showAiFeedback(feedback, settings.isHindi);
              } else if (mounted) {
                _showAiFeedback('Could not read amount clearly.', settings.isHindi);
              }
              
              if (mounted) setState(() => _isProcessing = false);
            }
          }
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _showAiFeedback(String text, bool isHindi) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: AppTheme.secondary,
        duration: const Duration(seconds: 8),
      ),
    );
    _ttsService.speak(text, isHindi: isHindi);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.split(' ').first ?? 'User';

    return Scaffold(
      extendBody: true, // Needed for transparent FAB notched bottom bar
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello, $displayName!", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18, color: AppTheme.onPrimary, fontWeight: FontWeight.bold)),
            Text("Current budget", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryContainer)),
          ],
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
               _isListening ? Icons.mic : Icons.mic_none, 
               color: _isListening ? Colors.red : AppTheme.surfaceContainerLowest
            ),
            onPressed: _listenToVoice,
          ),
          IconButton(
            icon: CircleAvatar(
              backgroundColor: AppTheme.surfaceContainerLowest,
              backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null ? const Icon(Icons.person, color: AppTheme.primary) : null,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()))
                  .then((_) => setState(() {})); // Refresh on return from profile
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          _screens[_currentIndex],
          if (_isProcessing)
             Container(
               color: Colors.black45,
               child: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
             )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _globalScanReceipt,
        backgroundColor: AppTheme.onSurface,
        child: const Icon(Icons.add, color: AppTheme.surface, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: AppTheme.surfaceContainerLowest,
        elevation: 16,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(icon: Icons.stacked_line_chart, label: 'Activity', index: 0),
            _buildTabItem(icon: Icons.analytics_outlined, label: 'Analyse', index: 1),
            const SizedBox(width: 48), // Space for FAB
            _buildTabItem(icon: Icons.smart_toy_outlined, label: 'AI', index: 2),
            _buildTabItem(icon: Icons.history_outlined, label: 'Reports', index: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.primary : AppTheme.outlineVariant;
    return GestureDetector(
      onTap: () {
        if (index < 4) {
           setState(() => _currentIndex = index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
