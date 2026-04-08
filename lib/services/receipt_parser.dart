import 'dart:convert';
import 'package:http/http.dart' as http;

class ReceiptParser {
  static final RegExp _amountRegex = RegExp(r'(?:rs\.?|inr|₹)\s*(\d+(?:\.\d{1,2})?)|\b(\d+(?:\.\d{1,2})?)\s*(?:rs|inr|₹|/-)', caseSensitive: false);
  static final RegExp _dateRegex = RegExp(r'(\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4})');

  static final Map<String, List<String>> _categoryKeywords = {
    'Food': ['restaurant', 'cafe', 'zomato', 'swiggy', 'canteen', 'food', 'hotel'],
    'Transport': ['uber', 'ola', 'petrol', 'diesel', 'taxi', 'auto', 'fuel', 'metro'],
    'Shopping': ['mall', 'store', 'mart', 'supermarket', 'clothing', 'retail'],
    'Bills': ['electricity', 'recharge', 'water', 'bill', 'broadband', 'airtel', 'jio'],
  };

  static Future<Map<String, dynamic>> parseWithAI(String text, String apiKey) async {
    if (apiKey.trim().isEmpty) {
        // --- RENDER HOSTED BACKEND FALLBACK ---
        // User can put their exact Render URL here (e.g. "https://my-backend.onrender.com")
        const String RENDER_BACKEND_URL = "https://your-backend-url.onrender.com"; 
        
        if (!RENDER_BACKEND_URL.contains("your-backend-url")) {
           try {
             final url = Uri.parse("$RENDER_BACKEND_URL/api/ocr");
             final prompt = '''You are a receipt parser. I will give you raw OCR text. Extract these 4 fields into a STRICT JSON object:
amount: (double, total numeric amount),
vendor: (string, the name of the store or app),
category: (string, exact match one of: Food, Transport, Shopping, Bills, Other),
date: (string in YYYY-MM-DD format).

Only output the raw valid JSON, nothing else. No markdown wrappers. Text: $text''';

             final res = await http.post(
               url,
               headers: {'Content-Type': 'application/json'},
               body: jsonEncode({"prompt": prompt})
             );
             
             if (res.statusCode == 200) {
                final data = jsonDecode(res.body);
                String rawJson = data['candidates'][0]['content']['parts'][0]['text'];
                rawJson = rawJson.replaceAll('```json', '').replaceAll('```', '').trim();
                Map<String, dynamic> parsed = jsonDecode(rawJson);
                return {
                  'amount': (parsed['amount'] as num?)?.toDouble() ?? 0.0,
                  'date': DateTime.tryParse(parsed['date'].toString()) ?? DateTime.now(),
                  'vendor': parsed['vendor']?.toString() ?? 'Unknown',
                  'category': parsed['category']?.toString() ?? 'Other'
                };
             }
           } catch (_) {}
        }
        
        return parse(text); // Fallback to regex local if all fails
    }
    
    try {
      final url = Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=$apiKey");
      final prompt = '''You are a receipt parser. I will give you raw OCR text. Extract these 4 fields into a STRICT JSON object:
amount: (double, total numeric amount),
vendor: (string, the name of the store or app),
category: (string, exact match one of: Food, Transport, Shopping, Bills, Other),
date: (string in YYYY-MM-DD format).

Only output the raw valid JSON, nothing else. No markdown wrappers. Text: $text''';

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{"parts":[{"text": prompt}]}]
        })
      );
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        String rawJson = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Strip markdown backticks if Gemini accidentally adds them
        rawJson = rawJson.replaceAll('```json', '').replaceAll('```', '').trim();
        Map<String, dynamic> parsed = jsonDecode(rawJson);
        
        return {
          'amount': (parsed['amount'] as num?)?.toDouble() ?? 0.0,
          'date': DateTime.tryParse(parsed['date'].toString()) ?? DateTime.now(),
          'vendor': parsed['vendor']?.toString() ?? 'Unknown',
          'category': parsed['category']?.toString() ?? 'Other'
        };
      }
    } catch (_) {}
    
    return parse(text);
  }

  static Map<String, dynamic> parse(String text) {
    // 1. Amount
    double amount = 0.0;
    final amountMatches = _amountRegex.allMatches(text);
    if (amountMatches.isNotEmpty) {
      // Find the largest number, loosely assuming it's the total.
      for (var match in amountMatches) {
        if (match.groupCount >= 1) {
          final val = double.tryParse(match.group(1) ?? '0');
          if (val != null && val > amount) {
            amount = val;
          }
        }
      }
    }

    // 2. Date
    DateTime date = DateTime.now();
    final dateMatch = _dateRegex.firstMatch(text);
    if (dateMatch != null) {
      try {
        final dateStr = dateMatch.group(0)!.replaceAll('-', '/').replaceAll('.', '/');
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          // Naive DD/MM/YYYY parsing mostly for simple strings
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          if (year < 100) year += 2000;
          date = DateTime(year, month, day);
        }
      } catch (e) {
        // fallback to now
      }
    }

    // 3. Vendor
    String vendor = 'Unknown Vendor';
    final lines = text.split('\n');
    if (lines.isNotEmpty) {
      // Usually vendor is the first non-empty line
      vendor = lines.firstWhere((element) => element.trim().isNotEmpty, orElse: () => 'Unknown Vendor').trim();
    }

    // 4. Category
    String category = 'Other';
    final lowerText = text.toLowerCase();
    for (var entry in _categoryKeywords.entries) {
      if (entry.value.any((keyword) => lowerText.contains(keyword))) {
        category = entry.key;
        break;
      }
    }

    return {
      'amount': amount,
      'date': date,
      'vendor': vendor,
      'category': category,
    };
  }
}
