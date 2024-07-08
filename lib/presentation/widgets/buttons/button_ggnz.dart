import 'package:flutter/material.dart';

class ButtonGGnz extends StatelessWidget {
  final RichText? textWidget;
  final String? buttonText;
  final TextStyle? style;
  final Color buttonColor;
  final Color buttonBorderColor;
  final double? width;
  final double? height;
  final double? elevation;
  final VoidCallback onPressed;
  final bool isBoxShadow;
  final String? imageUrl;
  final String? imageUrlUnderText;
  final bool? isOpacity;
  const ButtonGGnz(
      {Key? key,
      this.textWidget,
      this.buttonText = '',
      this.style = const TextStyle(
        fontFamily: 'ONE_Mobile_POP_OTF',
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      required this.buttonColor,
      required this.buttonBorderColor,
      this.width = 232,
      this.height = 50,
      this.elevation = 0,
      required this.onPressed,
      required this.isBoxShadow,
      this.imageUrl,
      this.imageUrlUnderText,
      this.isOpacity = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isOpacity! ? 0 : 1,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: isBoxShadow
                  ? [
                      BoxShadow(
                          color: buttonBorderColor, offset: const Offset(0, 4))
                    ]
                  : null),
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              elevation: elevation,
              minimumSize: Size(width!, height!),
              backgroundColor: buttonColor,
              shadowColor: buttonBorderColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(width: 3.0, color: buttonBorderColor)),
            ),
            child: textWidget != null
                ? textWidget!
                : imageUrl == null
                    ? Text(
                        buttonText!,
                        style: style,
                      )
                    : imageUrlUnderText == null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                '$imageUrl',
                                width: 30,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                buttonText!,
                                style: style,
                              )
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Image.asset(
                                    '$imageUrl',
                                    width: 30,
                                    fit: BoxFit.cover,
                                  ),
                                  Text(
                                    imageUrlUnderText!,
                                    style: style!.copyWith(fontSize: 8),
                                  )
                                ],
                              ),
                              Text(
                                buttonText!,
                                style: style,
                              )
                            ],
                          ),
          ),
        ),
      ),
    );
  }
}
