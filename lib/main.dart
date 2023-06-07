import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'dart:io' show Platform;
import 'package:desktop_window/desktop_window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    await FlutterDisplayMode.setHighRefreshRate();
  }
  else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await DesktopWindow.setWindowSize(const Size(1080, 1880));
  }
  runApp(const CalculatorApp());
}


class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFF2F4F6),
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Color(0xFFF2F4F6),
            statusBarIconBrightness: Brightness.dark,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: const Text(
            'Calculator',
            style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB1B8C0),
            ),
          ),
        ),
        body: const Calculator(),
      ),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({Key? key}) : super(key: key);

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  late TextEditingController _controller;
  List<double> _numbers = [];
  List<String> _operations = [];
  double _result = 0;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          final keyLabel = event.data.keyLabel;
          final logicalKey = event.logicalKey;

          if ('0'.compareTo(keyLabel) <= 0 && keyLabel.compareTo('9') <= 0) {
            _onNumberPressed(int.parse(keyLabel));
          } else if (keyLabel == '.') {
            _onDotPressed();
          } else if (logicalKey == LogicalKeyboardKey.enter) {
            _calculateResult();
          } else if (logicalKey == LogicalKeyboardKey.backspace) {
            _removeLastCharacter();
          }else if (logicalKey == LogicalKeyboardKey.delete) {
            _clear();
          } else if (keyLabel == '+' || keyLabel == '-' || keyLabel == '*' || keyLabel == '/') {
            _onOperationPressed(keyLabel);
          }
        }
      },
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: CustomTextField(
                controller: _controller,
                hintText: _isInteger(_result.toString()) ? _result.toInt().toString() : _result.toString(),
                clearText: _clear,
              ),
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            padding: const EdgeInsets.all(15),
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            crossAxisCount: 4,
            childAspectRatio: 1.0,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ...[7, 8, 9].map((i) => _buildButton(i.toString())),
              _buildButton('/', _onOperationPressed),
              ...[4, 5, 6].map((i) => _buildButton(i.toString())),
              _buildButton('*', _onOperationPressed),
              ...[1, 2, 3].map((i) => _buildButton(i.toString())),
              _buildButton('-', _onOperationPressed),
              _buildButton('0'),
              _buildButton('.', (_) => _onDotPressed()),
              _buildButton('=', (_) => _calculateResult()),
              _buildButton('+', _onOperationPressed),
            ],
          ),

          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "©️ 2023 Calculator by Seungpyo. All rights reserved.",
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB1B8C0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Remaining functions are as same as before

  Widget _buildButton(String title, [Function(String)? onPressed]) {
    return ButtonContainer(
      text: title,
      onPressed: () => onPressed?.call(title) ?? _onNumberPressed(int.parse(title)),
    );
  }

  void _onNumberPressed(int number) {
    setState(() {
      _controller.text = (_controller.text == '0' ? '' : _controller.text) + number.toString();
    });
  }

  void _onDotPressed() {
    setState(() {
      if (!_controller.text.contains('.')) {
        _controller.text = '${_controller.text}.';
      }
    });
  }

  void _onOperationPressed(String operation) {
    setState(() {
      if (_controller.text.isNotEmpty) {
        _numbers.add(double.parse(_controller.text));
        _controller.text = '';

        if (_operations.isNotEmpty) {
          double previousResult = _result;
          double currentNumber = _numbers.last;
          String previousOperation = _operations.last;

          switch (previousOperation) {
            case '+':
              _result = previousResult + currentNumber;
              break;
            case '-':
              _result = previousResult - currentNumber;
              break;
            case '*':
              _result = previousResult * currentNumber;
              break;
            case '/':
              _result = previousResult / currentNumber;
              break;
            default:
              break;
          }
        } else {
          _result = _numbers.first;
        }

        _operations.add(operation);
      }
    });
  }

  void _calculateResult() {
    setState(() {
      if (_controller.text.isNotEmpty) {
        _numbers.add(double.parse(_controller.text));
        _result = _numbers.first;
        _numbers.removeAt(0);

        for (int i = 0; i < _operations.length; i++) {
          switch (_operations[i]) {
            case '+':
              _result += _numbers[i];
              break;
            case '-':
              _result -= _numbers[i];
              break;
            case '*':
              _result *= _numbers[i];
              break;
            case '/':
              _result /= _numbers[i];
              break;
            default:
              break;
          }
        }

        _controller.text = _isInteger(_result.toString()) ? _result.toInt().toString() : _result.toString();
        _numbers = [];
        _operations = [];
      }
    });
  }

  void _clear() {
    setState(() {
      _controller.text = '0';
      _result = 0;
      _numbers = [];
      _operations = [];
    });
  }

  void _removeLastCharacter() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _controller.text = _controller.text.substring(0, _controller.text.length - 1);
      });
    }
  }

  bool _isInteger(String value) {
    final number = num.tryParse(value);
    return number != null && number.roundToDouble() == number;
  }
}

const textStyle = TextStyle(
  fontSize: 30.0,
  fontWeight: FontWeight.bold,
  color: Color(0xFFB1B8C0),
);

const textFieldStyle = TextStyle(
  fontSize: 40.0,
  fontWeight: FontWeight.bold,
  color: Color(0xFFB1B8C0),
);

class ButtonContainer extends StatelessWidget {
  final String text;
  final Function()? onPressed;

  const ButtonContainer({
    Key? key,
    required this.text,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(25.0),
      elevation: 3.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(25.0),
        onTap: onPressed,
        child: Container(
          alignment: Alignment.center,
          height: 80,
          child: Text(
            int.tryParse(text) != null ? int.parse(text).toString() : text,
            style: textStyle,
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final VoidCallback clearText;

  const CustomTextField({
    Key? key,
    this.hintText = '',
    required this.controller,
    required this.clearText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity!.compareTo(0) == -1) {
          clearText();
        } else if (details.primaryVelocity!.compareTo(0) == 1) {
          if (controller.text.isNotEmpty) {
            controller.text = controller.text.substring(0, controller.text.length - 1);
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Material(
          borderRadius: BorderRadius.circular(25.0),
          elevation: 3.0,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: TextField(
              controller: controller,
              maxLines: null,
              readOnly: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: textFieldStyle,
                alignLabelWithHint: true,
              ),
              style: textFieldStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

