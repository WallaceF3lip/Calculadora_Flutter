enum OperationTypeEnum {
  addition(symbol: '+'),
  subtraction(symbol: '-'),
  multiplication(symbol: 'X'),
  division(symbol: '÷');

  final String symbol;
  const OperationTypeEnum({required this.symbol});
}