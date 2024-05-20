// ignore_for_file: library_private_types_in_public_api

// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/screen_size_configs.dart';

class RoundedTextField extends StatefulWidget {
  final String labelText;
  final bool obscureText;
  final List<String> items;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final ValueChanged<String?>? onChanged;
  final bool isBirthdayField;

  const RoundedTextField({
    Key? key,
    required this.labelText,
    this.obscureText = false,
    this.items = const [],
    this.validator,
    this.controller,
    this.onChanged,
    this.isBirthdayField = false,
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
          ? _buildDropdownFormField()
          : _buildDateFormField(),
    );
  }

  Widget _buildDropdownFormField() {
    return DropdownButtonFormField<String>(
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
    );
  }

  Widget _buildDateFormField() {
    return TextFormField(
      controller: widget.controller,
      onTap: widget.isBirthdayField ? _pickDate : null,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        labelText: widget.labelText,
        border: InputBorder.none,
        suffixIcon: _buildSuffixIcon(),
        prefixStyle: const TextStyle(
          color: Colors.black,
          fontSize: SSC.p16,
        ),
      ),
      obscureText: _isObscure && (widget.obscureText),
      validator: widget.validator,
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            _isObscure = !_isObscure;
          });
        },
      );
    } else if (widget.isBirthdayField) {
      return IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: _pickDate,
      );
    }
    return null;
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Palette.MAIN,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      widget.controller?.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }
}
