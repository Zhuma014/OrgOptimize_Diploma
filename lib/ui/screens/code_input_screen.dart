// ignore_for_file: library_private_types_in_public_api

// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/app.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/utils/screen_size_configs.dart';

class CodeInputScreen extends StatefulWidget {
  const CodeInputScreen({super.key});

  @override
  _CodeInputScreenState createState() => _CodeInputScreenState();
}

class _CodeInputScreenState extends State<CodeInputScreen> {
  late List<String?> _code;
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _code = List.filled(4, null);
    _focusNodes = List.generate(4, (index) => FocusNode());
    _controllers = List.generate(4, (index) => TextEditingController());
    _focusNodes[0].requestFocus();
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.BACKGROUND,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: SSC.p172),
              Text(
               LU.of(context).enter_code,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: SSC.p42,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: SSC.p108),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => SizedBox(
                    width: SSC.p55,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _code[index] != null
                            ? Colors.red
                            : Colors.grey[200],
                      ),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        onChanged: (value) {
                          if (value.length > 1) {
                            _controllers[index].clear();
                          } else if (value.isNotEmpty) {
                            _code[index] = value;
                            if (index < 3) {
                              _focusNodes[index + 1].requestFocus();
                            }
                          }
                          setState(() {});
                        },
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                            fontSize: SSC.p22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SSC.p108),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const UrvenApp()),
                      ModalRoute.withName('/'),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.YELLOWBUTTON,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: Text(LU.of(context).next, style: const TextStyle(color: Colors.black)),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(horizontal: 19),
                    ),
                  ),
                  child: Text(
                    LU.of(context).resend_code,
                    style: const TextStyle(
                      color: Palette.YELLOWBUTTON,
                      fontSize: SSC.p14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
