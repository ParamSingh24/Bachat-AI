import 'package:flutter/material.dart';

class GeminiNanoShowcaseScreen extends StatefulWidget {
  const GeminiNanoShowcaseScreen({super.key});

  @override
  State<GeminiNanoShowcaseScreen> createState() => _GeminiNanoShowcaseScreenState();
}

class _GeminiNanoShowcaseScreenState extends State<GeminiNanoShowcaseScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  bool _isProcessing = false;

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.insert(0, "User: $text");
      _isProcessing = true;
    });
    
    _controller.clear();

    // Simulating Local "Gemini Nano" processing delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _messages.insert(0, "Gemini Nano: Processing locally on-device... Here is a mock response for: '$text'");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Nano (Local AI)'),
        backgroundColor: Colors.blueAccent,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.memory, size: 16, color: Colors.white),
                SizedBox(width: 4),
                Text("On-Device", style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blueAccent.withOpacity(0.1),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blueAccent),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "This is a showcase screen demonstrating where local AI processing (via Gemini Nano) would execute completely on-device without internet.",
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final isUser = _messages[index].startsWith("User:");
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _messages[index],
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text("Gemini Nano is inferencing...", style: TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _handleSubmitted,
                    decoration: InputDecoration(
                      hintText: "Test local prompt...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: () => _handleSubmitted(_controller.text),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16), // SafeArea padding
        ],
      ),
    );
  }
}
