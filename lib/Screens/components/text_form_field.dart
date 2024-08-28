import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool obscureText;
  final bool enabled;
  final Widget? suffixIcon;
  final String? error;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    Key? key,
    this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.suffixIcon,
    this.error,
    this.validator,
  }) : super(key: key);

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _obscureText;

  @override
  void initState() {
    _obscureText = widget.obscureText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Color(0xffD9D9D9),
      height: 6.h,
      width: 70.h,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        color: Color(0xffD9D9D9),
      ),
      /*decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xfff2f2f2), //color of border
            width: 1, //width of border
          ),
          borderRadius: BorderRadius.circular(5)),*/
      child: Center(
        child: TextFormField(
          // initialValue: "@resustainability.com",
          key: const ValueKey('customTextFormField'),
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          controller: widget.controller,
          enabled: widget.enabled,
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.only(left: 10.0),
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              fontSize: 16,
              color: Color(0xffbcbcbc),
              fontFamily: 'ARIAL',
            ),
            errorText: widget.error,
            suffixIcon: widget.obscureText
                ? GestureDetector(
              onTap: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  size: 15,
                ),
              ),
            )
                : widget.suffixIcon,
          ),

          style: const TextStyle(
            fontSize: 16,
            color: Color(0xff575757),
            fontFamily: 'ARIAL',
          ),
          cursorColor: Colors.black,
          cursorWidth: 1,
          validator: widget.validator,
        ),
      ),
    );
  }
}
