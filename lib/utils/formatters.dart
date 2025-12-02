import 'package:flutter/services.dart';

class CpfCnpjFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'\D'), '');
    var newText = "";
    
    if (text.length <= 11) {
      // CPF: XXX.XXX.XXX-XX
      for (var i = 0; i < text.length; i++) {
        if (i == 3 || i == 6) newText += ".";
        if (i == 9) newText += "-";
        newText += text[i];
      }
    } else {
      // CNPJ: XX.XXX.XXX/XXXX-XX
      for (var i = 0; i < text.length; i++) {
        if (i == 2 || i == 5) newText += ".";
        if (i == 8) newText += "/";
        if (i == 12) newText += "-";
        newText += text[i];
      }
    }
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'\D'), '');
    var newText = "";
    
    // (XX) XXXXX-XXXX
    for (var i = 0; i < text.length; i++) {
      if (i == 0) newText += "(";
      if (i == 2) newText += ") ";
      if (i == 7) newText += "-";
      newText += text[i];
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}