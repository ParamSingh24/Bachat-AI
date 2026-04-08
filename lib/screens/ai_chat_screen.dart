import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../providers/expense_provider.dart';
import '../services/ai_logic_engine.dart';
import '../providers/settings_provider.dart';
import '../services/tts_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class _AiChatScreenState extends State<AiChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _forceEnglish = false;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: "Hello! I am your AI Budget Assistant. Ask me about your spending, total budget, or specific categories.",
      isUser: false,
    ));
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    _controller.clear();
    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUser: true));
    });

    // Simulate slight delay for "AI" thinking
    Future.delayed(const Duration(milliseconds: 600), () {
      _generateResponse(text);
    });
  }

  void _listenToVoice() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (val) {
          if (mounted) setState(() => _isListening = false);
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          if (val.finalResult) {
            setState(() => _isListening = false);
            _handleSubmitted(val.recognizedWords);
          } else {
             // Show intermediate text in input field
             _controller.text = val.recognizedWords;
             _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
          }
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _generateResponse(String userText) async {
    final provider = context.read<ExpenseProvider>();
    final isHindi = _forceEnglish ? false : context.read<SettingsProvider>().isHindi;
    final apiKey = context.read<SettingsProvider>().geminiApiKey;
    
    String response = "I'm not sure about that. Try asking about your total spend.";

    if (apiKey.trim().isNotEmpty) {
       // Use Gemini Live API directly
       try {
         final url = Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=$apiKey");
         final budgetContext = "You are Bachat AI, a mature adult financial advisor AI. The user has a total spend of ₹${provider.totalExpenses.toStringAsFixed(2)}. Category breakdown: ${provider.categoryBreakdown.toString()}. Please answer concisely in text. The language should be ${isHindi ? 'Hindi' : 'English'}. Reply to this user message: $userText";
         
         final res = await http.post(
           url,
           headers: {'Content-Type': 'application/json'},
           body: jsonEncode({
             "contents": [{"parts":[{"text": budgetContext}]}]
           })
         );
         
         if (res.statusCode == 200) {
           final data = jsonDecode(res.body);
           response = data['candidates'][0]['content']['parts'][0]['text'];
         } else {
           response = "API Error: ${res.statusCode} - Ensure your API Key is correct and has quota.";
         }
       } catch (e) {
         response = "Internet error reaching Gemini: $e";
       }
    } else {
       // --- RENDER HOSTED BACKEND FALLBACK ---
       // User can put their exact Render URL here (e.g. "https://my-backend.onrender.com")
       const String RENDER_BACKEND_URL = "https://mindforge-param.onrender.com"; 
       
       if (RENDER_BACKEND_URL.contains("your-backend-url")) {
           // Basic heuristic matching fallback if render URL is not set
           final lowerText = userText.toLowerCase();
           if (lowerText.contains("total") || lowerText.contains("spend")) {
             response = "You have spent a total of ₹${provider.totalExpenses.toStringAsFixed(2)} so far.";
           } else if (lowerText.contains("food")) {
             double amt = provider.categoryBreakdown['Food'] ?? 0;
             response = "You have spent ₹${amt.toStringAsFixed(2)} on Food.";
           } else if (lowerText.contains("advice") || lowerText.contains("budget")) {
             if (provider.categoryBreakdown.isNotEmpty) {
               var topCat = provider.categoryBreakdown.entries.reduce((a, b) => a.value > b.value ? a : b);
               response = BudgetStrategist.generateLocalSuggestion(0, topCat.key, topCat.value, isHindi: isHindi);
             } else {
               response = "You don't have any expenses yet. Scan some receipts!";
             }
           }
       } else {
           try {
             final url = Uri.parse("$RENDER_BACKEND_URL/api/chat");
             final budgetContext = "You are Bachat AI, a mature adult financial advisor AI. The user has a total spend of ₹${provider.totalExpenses.toStringAsFixed(2)}. Category breakdown: ${provider.categoryBreakdown.toString()}. Please answer concisely in text. The language should be ${isHindi ? 'Hindi' : 'English'}. Reply to this user message: $userText";
             
             final res = await http.post(
               url,
               headers: {'Content-Type': 'application/json'},
               body: jsonEncode({"text": budgetContext})
             );
             if (res.statusCode == 200) {
                 final data = jsonDecode(res.body);
                 response = data['candidates'][0]['content']['parts'][0]['text'];
             } else {
                 response = "Render Backend Error: ${res.statusCode}";
             }
           } catch (e) {
             response = "Error reaching Render Backend: $e";
           }
       }
    }

    // Play TTS
    TtsService().speak(response, isHindi: isHindi);

    if (mounted) {
      setState(() {
        _messages.insert(0, ChatMessage(text: response, isUser: false));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return _buildMessageBubble(message);
            },
          ),
        ),
        const Divider(height: 1),
        Container(
          decoration: const BoxDecoration(color: AppTheme.surfaceContainerLowest),
          child: _buildTextComposer(),
        ),
        const SizedBox(height: 120), // Padding for Floating dock
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: const CircleAvatar(
                backgroundColor: AppTheme.primaryContainer,
                child: Icon(Icons.smart_toy, color: AppTheme.primary, size: 20),
              ),
            ),
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: message.isUser ? AppTheme.primary : AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: message.isUser ? const Radius.circular(16) : const Radius.circular(0),
                  bottomRight: message.isUser ? const Radius.circular(0) : const Radius.circular(16),
                ),
              ),
              child: Text(
                message.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: message.isUser ? AppTheme.onPrimary : AppTheme.onSurface,
                ),
              ),
            ),
          ),
          
          if (message.isUser)
            Container(
              margin: const EdgeInsets.only(left: 16.0),
              child: const CircleAvatar(
                backgroundColor: AppTheme.surfaceContainerLow,
                child: Icon(Icons.person, color: AppTheme.outlineVariant, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: const IconThemeData(color: AppTheme.primary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            InkWell(
               onTap: () {
                 setState(() {
                    _forceEnglish = !_forceEnglish;
                 });
                 ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('AI set to ${_forceEnglish ? "English only" : "Default config"}'), duration: const Duration(seconds: 1)),
                 );
               },
               child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                     color: _forceEnglish ? AppTheme.primary : AppTheme.surfaceContainerLow,
                     borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('ENG', style: TextStyle(color: _forceEnglish ? Colors.white : AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
               ),
            ),
            Flexible(
              child: TextField(
                controller: _controller,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration(
                  hintText: "Ask AI about your budget...",
                  filled: true,
                  fillColor: AppTheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              child: IconButton(
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : AppTheme.primary),
                onPressed: _listenToVoice,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
