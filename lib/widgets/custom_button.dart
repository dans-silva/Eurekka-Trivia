import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? buttonColor;
  final double borderRadius;
  final Color? textColor; // Nova propriedade para cor do texto

  const CustomButton({
    required this.text,
    this.icon,
    required this.onPressed,
    this.buttonColor,
    this.borderRadius = 8.0,
    this.textColor, // Adicionado parâmetro para cor do texto
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor ?? const Color(0xFFFFC75D), // #FFC75D
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
                color: textColor ??
                    Colors.black), // Aplica a cor do texto ou preto por padrão
          ),
          if (icon != null) ...[
            SizedBox(width: 8),
            Icon(icon,
                color:
                    textColor ?? Colors.black), // Aplica a mesma cor ao ícone
          ],
        ],
      ),
    );
  }
}
