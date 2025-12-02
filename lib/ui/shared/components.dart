import 'package:flutter/material.dart';
import '../../models/feedback_form.dart';

class FormSectionLayout extends StatelessWidget {
  final String? title;
  final Widget content;
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final String nextLabel;
  final bool isNextEnabled;

  const FormSectionLayout({
    super.key,
    this.title,
    required this.content,
    this.onNext,
    this.onBack,
    this.nextLabel = "Próximo",
    this.isNextEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // FIX: Removed 'Center'. Used Align Top + SafeArea for mobile stability.
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // Better feel on iOS
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                ],
                
                // --- MAIN CARD ---
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0A2458), 
                        const Color(0xFF001343).withOpacity(0.8), 
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: content,
                ),
                
                const SizedBox(height: 32),
                
                // --- NAVIGATION BUTTONS ---
                Row(
                  children: [
                    if (onBack != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onBack,
                          child: const Text("VOLTAR"),
                        ),
                      ),
                    if (onBack != null) const SizedBox(width: 20),
                    if (onNext != null)
                      Expanded(
                        flex: 2, 
                        child: ElevatedButton(
                          onPressed: isNextEnabled ? onNext : null,
                          style: ElevatedButton.styleFrom(
                            disabledBackgroundColor: Colors.white.withOpacity(0.1),
                            disabledForegroundColor: Colors.white38,
                          ),
                          child: Text(nextLabel.toUpperCase()),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DynamicInformativeText extends StatelessWidget {
  final String template;
  final FeedbackForm data;

  const DynamicInformativeText({
    super.key,
    required this.template,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    String processedText = template.replaceAllMapped(RegExp(r'\{\{\s*(\w+)\s*([!=]=)\s*(.*?)\s*\?\s*(.*?)\s*:\s*(.*?)\s*\}\}'), (match) {
      final key = match.group(1)!;
      final operator = match.group(2)!;
      final compareValueRaw = match.group(3)!;
      final trueText = match.group(4)!.replaceAll("'", ""); 
      final falseText = match.group(5)!.replaceAll("'", ""); 

      final actualValue = data[key]?.toString() ?? '';
      final compareValue = compareValueRaw == "''" || compareValueRaw == '""' ? "" : compareValueRaw.replaceAll("'", "");
      
      bool conditionMet = false;
      if (operator == '==') conditionMet = actualValue == compareValue;
      else if (operator == '!=') conditionMet = actualValue != compareValue;
      return conditionMet ? trueText.replaceAll(r'\n', '\n') : falseText.replaceAll(r'\n', '\n');
    });

    processedText = processedText.replaceAllMapped(RegExp(r'\{(\w+)\}'), (match) {
      final key = match.group(1);
      final value = data[key!];
      return value?.toString() ?? '...';
    });

    List<Widget> spans = [];
    List<String> lines = processedText.split('\n');
    const accentColor = Color(0xFF00CCFF); 
    
    for (String line in lines) {
      if (line.startsWith('### ')) {
        spans.add(Text(
          line.substring(4),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentColor),
        ));
      } else if (line.startsWith('- ')) {
         spans.add(Padding(
           padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
           child: Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const Icon(Icons.arrow_right, size: 20, color: accentColor),
               const SizedBox(width: 4),
               Expanded(child: Text(line.substring(2), style: const TextStyle(color: Colors.white70, fontSize: 16))),
             ],
           ),
         ));
      } else {
        List<InlineSpan> inlineSpans = [];
        line.splitMapJoin(
          RegExp(r'\*\*(.*?)\*\*'),
          onMatch: (m) {
            inlineSpans.add(TextSpan(text: m.group(1), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)));
            return '';
          },
          onNonMatch: (n) {
            inlineSpans.add(TextSpan(text: n));
            return '';
          },
        );
        spans.add(RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
            children: inlineSpans,
          ),
        ));
      }
      if (!line.startsWith('- ')) spans.add(const SizedBox(height: 8)); 
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF00CCFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: spans,
      ),
    );
  }
}

Widget buildQuestion(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600, 
        fontSize: 18, 
        color: Colors.white,
        height: 1.3
      ),
    ),
  );
}

Widget buildRadioGroup({
  required List<String> options,
  required String selected,
  required Function(String) onSelect,
}) {
  return Column(
    children: options.map((opt) {
      final isSelected = selected == opt;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00CCFF).withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00CCFF) : Colors.transparent,
            width: 2
          ),
        ),
        child: RadioListTile<String>(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            opt, 
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          value: opt,
          groupValue: selected,
          activeColor: const Color(0xFF00CCFF),
          onChanged: (val) {
            if (val != null) onSelect(val);
          },
        ),
      );
    }).toList(),
  );
}