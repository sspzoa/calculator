import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDisplayMode.setHighRefreshRate();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(const CalculatorApp());
  });
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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }

  Widget _buildButton(String title, [Function(String)? onPressed]) {
    return ButtonContainer(
      child: TextButton(
        onPressed: () => onPressed?.call(title) ?? _onNumberPressed(int.parse(title)),
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.transparent),
        ),
        child: Text(
          _isInteger(title) ? int.parse(title).toString() : title,
          style: textStyle,
        ),
      ),
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
        _controller.text = _controller.text + '.';
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

  bool _isInteger(String value) {
    final number = num.tryParse(value);
    return number != null && number % 1 == 0;
  }
}

const textStyle = TextStyle(
  fontSize: 25.0,
  fontWeight: FontWeight.bold,
  color: Color(0xFFB1B8C0),
);

const textFieldStyle = TextStyle(
  fontSize: 40.0,
  fontWeight: FontWeight.bold,
  color: Color(0xFFB1B8C0),
);

final boxDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(15.0),
  border: Border.all(
    color: const Color(0xFFB1B8C0).withOpacity(0.1),
    width: 1,
  ),
);

class ButtonContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const ButtonContainer({
    required this.child,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        decoration: boxDecoration,
        child: child,
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
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: TextField(
          controller: controller,
          maxLines: null,
          readOnly: true,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: textFieldStyle,
            border: InputBorder.none,
            alignLabelWithHint: true,
          ),
          style: textFieldStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
