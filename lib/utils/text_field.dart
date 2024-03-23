// ignore_for_file: library_private_types_in_public_api

// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/utils/screen_size_configs.dart';

class RoundedTextField extends StatefulWidget {
  final String labelText;
  final bool obscureText;
  final List<String> items;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final ValueChanged<String?>? onChanged;

  const RoundedTextField({
    Key? key,
    required this.labelText,
    this.obscureText = false,
    this.items = const [],
    this.validator,
    this.controller,
    this.onChanged,
  }) : super(key: key);

  @override
  _RoundedTextFieldState createState() => _RoundedTextFieldState();
}

class _RoundedTextFieldState extends State<RoundedTextField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.grey[200],
      ),
      child: widget.items.isNotEmpty
          ? DropdownButtonFormField<String>(
              value: widget.controller?.text,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                labelText: widget.labelText,
                border: InputBorder.none,
              ),
              items: widget.items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            )
          : TextFormField(
              controller: widget.controller,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                labelText: widget.labelText,
                border: InputBorder.none,
                suffixIcon: (widget.obscureText && widget.labelText == LU.of(context).password) || (widget.obscureText && widget.labelText == LU.of(context).new_password)
                    ? IconButton(
                        icon: Icon(_isObscure
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      )
                    : null,
                prefixText: widget.labelText == LU.of(context).phone_number ? '+7 ' : '',
                 prefixStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: SSC.p16
                ),
              ),
obscureText: (_isObscure && widget.labelText == LU.of(context).password) || (_isObscure && widget.labelText == LU.of(context).new_password),
              validator: widget.validator,
            ),
    );
  }
}
