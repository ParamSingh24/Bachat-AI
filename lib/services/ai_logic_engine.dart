import 'dart:math';

class BudgetStrategist {
  static const double monthlyBudget = 10000.0;

  static String generateLocalSuggestion(double amountScanned, String category, double categoryTotal, {bool isHindi = false}) {
    if (categoryTotal > 3000) {
      if (category == 'Food') {
        return isHindi 
          ? 'आपके भोजन का खर्च काफी अधिक है। बाहर खाना कम करें। स्वास्थ्य और बजट दोनों के लिए घर का भोजन बेहतर है।'
          : 'Your dining expenses are disproportionately high this cycle. I recommend consolidating your meal planning at home to recover variance in your budget.';
      } else if (category == 'Transport') {
        return isHindi
          ? 'आप यात्रा पर बहुत खर्च कर रहे हैं। सार्वजनिक परिवहन या कारपूलिंग पर विचार करें।'
          : 'Transportation costs are trending sharply upward. Consider evaluating public transit, carpooling, or consolidating errands to optimize your cash flow.';
      } else {
        return isHindi
          ? '$category पर आपका खर्च बजट से बाहर जा रहा है। कृपया इसे नियंत्रित करें।'
          : 'Expenditure in the $category category requires immediate auditing. You are pacing above the recommended baseline for logical wealth accrual.';
      }
    } else {
      return isHindi 
        ? 'आपका खर्च नियंत्रण में है। इसी तरह बचत करते रहें।'
        : 'Your short-term liquidity management is sound. Continue maintaining these optimized saving habits.';
    }
  }
}
