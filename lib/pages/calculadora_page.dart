import 'package:calculadora/enum/operation_type.dart';
import 'package:calculadora/pages/historic_page.dart';
import 'package:calculadora/widgets/button_widgets.dart';
import 'package:flutter/material.dart';

class CalculadoraPage extends StatefulWidget {
  const new({super.key});

  @override
  State<CalculadoraPage> createState() => _CalculadoraPageState();
}

class _CalculadoraPageState extends State<CalculadoraPage> {
  late String displayNumber;
  late List<String> historic;

  @override

  void initState() {
    displayNumber = '0';
    historic = [];
    super.initState();
  }

  void setOperationType(OperationTypeEnum newType) {
    final lastChar = displayNumber.isNotEmpty ? displayNumber.characters.last : '';
    final operationSymbols = OperationTypeEnum.values.map((e) => e.symbol).toSet();

    setState(() {
      if (lastChar.isNotEmpty && !operationSymbols.contains(lastChar)) {
        displayNumber += newType.symbol;
      }else{
        displayNumber = displayNumber.substring(0, displayNumber.length - 1) + newType.symbol;
      }
    });
  }

  void clear(){
    setState(() {
      displayNumber = '0';
    });
  }

  void appendNumber(String stringNumber) {
    setState(() {
      if (displayNumber == '0') {
        displayNumber = stringNumber;
      }else{
        displayNumber += stringNumber;        
      }
    });
  }

  List<double> parseNumber(String expression) {
    RegExp regExp = RegExp(r'[0-9]+\.?[0-9]*');

    var matches = regExp.allMatches(expression);
    List<double> numbers = [];

    for (var match in matches) {
      String numberText = match.group(0)!;
      numbers.add(double.parse(numberText));
    }

    return numbers;
  }

  List<OperationTypeEnum> getOperators(String expression) {
    final expression1 = expression.characters.where(
      (x) => OperationTypeEnum.values.any((op) => op.symbol == x)
    );

    return expression1
      .map((x) => OperationTypeEnum.values.firstWhere((op) => op.symbol == x))
      .toList();
  }

  void backSpace(){
    setState(() {
      if(displayNumber.length > 1){
        displayNumber = displayNumber.substring(0, displayNumber.length - 1);        
      }else{
        displayNumber = '0';
      }
    });
  }

  void resolvePriorityOperations(List<double> numbers, List<OperationTypeEnum> operations) {
    int i = 0;
    while ( i < operations.length ) {
      if (operations[i] == OperationTypeEnum.multiplication) {
        numbers[i] = numbers[i] * numbers[i + 1];
        numbers.removeAt(i + 1);
        operations.removeAt(i);

      } else if(operations[i] == OperationTypeEnum.division) {
        numbers[i] = numbers[i] / numbers[i + 1];
        numbers.removeAt(i + 1);
        operations.removeAt(i);

      } else {
        i++; 
      }
    }
  }

  double resolveAdditionAndSubtraction(List<double> numbers, List<OperationTypeEnum> operations){
    int i = 0;
    while ( i < operations.length ) {
      if (operations[i] == OperationTypeEnum.addition) {
        numbers[0] = numbers[0] + numbers[i + 1];
        // numbers.removeAt(i + 1);

      } else {
        numbers[0] = numbers[0] - numbers[i + 1];
        // numbers.removeAt(i + 1);
      }

      i++; 
    }
    return numbers[0];
  }

  void calculate(){
    String expression = displayNumber.replaceAll(',', '.');
    List<double> numbers = parseNumber(expression);
    List<OperationTypeEnum> operations = getOperators(expression);
    
    resolvePriorityOperations(numbers, operations);
    final result = resolveAdditionAndSubtraction(numbers, operations);
    
    setState(() {
      displayNumber = result.toString().replaceAll('.', ','); 
      historic.add("$expression = $result");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, 
        title: const Text('Calculadora'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:(context) => HistoricPage(historic: historic,)
                )
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.maxFinite,
            color: Colors.black12,
            child: Align(
              alignment: .bottomRight,
              child: Text(
                displayNumber,
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      ButtonWidgets(
                        text: 'C',
                        color: Colors.red,
                        onPressed: () {
                          clear();
                        },
                      ),
                      ButtonWidgets(
                        text: '\u232B',
                        color: Colors.orange,
                        onPressed: () {
                          backSpace();
                        },
                      ),
                      ButtonWidgets(
                        text: '÷',
                        color: Colors.blue,
                        textColor: Colors.white,
                        onPressed: () {
                          setOperationType(OperationTypeEnum.division);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      ButtonWidgets(
                        text: '7',
                        onPressed: () {
                          appendNumber('7');
                        },
                      ),
                      ButtonWidgets(
                        text: '8',
                        onPressed: () {
                          appendNumber('8');
                        },
                      ),
                      ButtonWidgets(
                        text: '9',
                        onPressed: () {
                          appendNumber('9');
                        },
                      ),
                      ButtonWidgets(
                        text: 'X',
                        onPressed: () {
                          setOperationType(OperationTypeEnum.multiplication);
                        },
                        color: Colors.blue,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      ButtonWidgets(
                        text: '4',
                        onPressed: () {
                          appendNumber('4');
                        },
                      ),
                      ButtonWidgets(
                        text: '5',
                        onPressed: () {
                          appendNumber('5');
                        },
                      ),
                      ButtonWidgets(
                        text: '6',
                        onPressed: () {
                          appendNumber('6');
                        },
                      ),
                      ButtonWidgets(
                        text: '-',
                        onPressed: () {
                          setOperationType(OperationTypeEnum.subtraction);
                        },
                        color: Colors.blue,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      ButtonWidgets(
                        text: '1',
                        onPressed: () {
                          appendNumber('1');
                        },
                      ),
                      ButtonWidgets(
                        text: '2',
                        onPressed: () {
                          appendNumber('2');
                        },
                      ),
                      ButtonWidgets(
                        text: '3',
                        onPressed: () {
                          appendNumber('3');
                        },
                      ),
                      ButtonWidgets(
                        text: '+',
                        onPressed: () {
                          setOperationType(OperationTypeEnum.addition);
                        },
                        color: Colors.blue,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      ButtonWidgets(
                        text: '0',
                        onPressed: () {
                          appendNumber('0');
                        },
                      ),
                      ButtonWidgets(
                        text: ',',
                        onPressed: () {
                          appendNumber(',');
                        },
                      ),
                      ButtonWidgets(
                        text: '=',
                        onPressed: () {
                          calculate();
                        },
                        color: Colors.green,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
