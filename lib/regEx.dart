import 'package:flutter/services.dart';

enum InputFormatterType { alphanumeric, name, email, numeric }

class RegEx extends TextInputFormatter {
  final InputFormatterType type;

  RegEx({required this.type});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Verificar si el nuevo texto comienza con un espacio (común para varios casos)
    if (newValue.text.startsWith(' ')) {
      return oldValue;
    }

    // Verificar si el nuevo texto comienza con un espacio
    /*if (newValue.text.startsWith(' ')) {
      return oldValue; // No permitimos que comience con espacio
    }

    // Permitir eliminar espacios finales de forma controlada
    if (oldValue.text.endsWith(' ') &&
        !newValue.text.endsWith(' ') &&
        newValue.text.length == oldValue.text.length - 1 &&
        oldValue.text.length > 1) {
      return newValue;
    }*/

    // Definir diferentes reglas basadas en el tipo de formateador
    switch (type) {
      case InputFormatterType.alphanumeric:
        if (oldValue.text.endsWith(' ') &&
            !newValue.text.endsWith(' ') &&
            newValue.text.length == oldValue.text.length - 1 &&
            oldValue.text.length > 1) {
          return newValue;
        }
        return FilteringTextInputFormatter.allow(
          RegExp(r'[a-zA-ZñÑáéíóúÁÉÍÓÚüÜ0-9\s]'),
        ).formatEditUpdate(oldValue, newValue);

      case InputFormatterType.name:
      // Verificar si el texto anterior termina con un espacio y el nuevo texto no
      // Esto indica que el usuario está intentando eliminar un espacio final
        if (oldValue.text.endsWith(' ') &&
            !newValue.text.endsWith(' ') &&
            newValue.text.length == oldValue.text.length - 1 &&
            oldValue.text.length > 1) {
          // Permitimos la eliminación del espacio final
          return newValue;
        }
        return FilteringTextInputFormatter.allow(
          RegExp(r'[a-zA-ZñÑáéíóúÁÉÍÓÚüÜ0-9\s]'),
        ).formatEditUpdate(oldValue, newValue);

      case InputFormatterType.email:
      // Permitir borrar un espacio intermedio
        if (oldValue.text.endsWith(' ') &&
            !newValue.text.endsWith(' ') &&
            newValue.text.length == oldValue.text.length - 1 &&
            oldValue.text.length > 1) {
          return newValue;
        }

        // Aplicar filtros de caracteres permitidos y denegados
        String filteredText = newValue.text;

        // Filtrar los caracteres permitidos
        filteredText = RegExp(r'[a-zA-Z0-9._%-@]')
            .allMatches(filteredText)
            .map((match) => match.group(0))
            .join();

        // Negar los caracteres no permitidos
        filteredText = filteredText.replaceAll(RegExp(r'[<>?:;/+%]'), '');

        return TextEditingValue(
          text: filteredText,
          selection: newValue.selection.copyWith(
            baseOffset: filteredText.length,
            extentOffset: filteredText.length,
          ),
        );

      case InputFormatterType.numeric:
        return FilteringTextInputFormatter.allow(
          RegExp(r'[0-9@.\-_]'), // Letras, números y caracteres de correo
        ).formatEditUpdate(oldValue, newValue);

      default:
        return newValue;
    }
  }
}

class AlfaNumericInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.startsWith(' ')) {
      return oldValue;
    }
    if (oldValue.text.endsWith(' ') &&
        !newValue.text.endsWith(' ') &&
        newValue.text.length == oldValue.text.length - 1 &&
        oldValue.text.length > 1) {
      return newValue;
    }
    return FilteringTextInputFormatter.allow(
      RegExp(r'[a-zA-ZñÑ0-9\s]'),
    ).formatEditUpdate(oldValue, newValue);
  }
}

class NameInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Verificar si el nuevo texto comienza con un espacio
    if (newValue.text.startsWith(' ')) {
      // Si comienza con un espacio, no permitimos la actualización y devolvemos el valor anterior
      return oldValue;
    }

    // Verificar si el texto anterior termina con un espacio y el nuevo texto no
    // Esto indica que el usuario está intentando eliminar un espacio final
    if (oldValue.text.endsWith(' ') &&
        !newValue.text.endsWith(' ') &&
        newValue.text.length == oldValue.text.length - 1 &&
        oldValue.text.length > 1) {
      // Permitimos la eliminación del espacio final
      return newValue;
    }
    return FilteringTextInputFormatter.allow(
      RegExp(r'[a-zA-ZñÑ0-9\s]'), // Expresión regular que permite letras y espacios
    ).formatEditUpdate(oldValue, newValue);
  }
}
